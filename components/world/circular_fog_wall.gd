extends Node3D
class_name CircularFogWall

## Pared circular de niebla espesa que encierra al jugador durante los encuentros de combate.
## Creada enteramente mediante niebla volumétrica (FogVolume), partículas de humo y barrera física.

static var has_experienced_fog_encounter: bool = false

@export var radius: float = 17.5
@export var wall_height: float = 12.0
@export var fog_thickness: float = 5.5
@export var max_fog_density: float = 4.5
@export var fade_in_time: float = 1.4
@export var fade_out_time: float = 2.0

var fade_amount: float = 0.0:
	set(val):
		fade_amount = clampf(val, 0.0, 1.0)
		_update_fog_volume(fade_amount)

var is_active: bool = false
var is_dissolving: bool = false

var _fog_volume: FogVolume = null
var _fog_material: ShaderMaterial = null
var _particles: GPUParticles3D = null
var _static_body: StaticBody3D = null
var _collision_shapes: Array[CollisionShape3D] = []
var _repel_area: Area3D = null
var _audio_player: AudioStreamPlayer = null

var _world_env: WorldEnvironment = null
var _orig_fog_density: float = 0.04
var _orig_fog_color: Color = Color(1.0, 1.0, 1.0)
var _env_tweener: Tween = null

var _player_in_fog: CharacterBody3D = null

func _notification(what: int) -> void:
	if what == NOTIFICATION_PREDELETE or what == NOTIFICATION_UNPARENTED:
		_restore_world_environment()

func _ready() -> void:
	_build_volumetric_fog()
	_build_particles()
	_build_collision_ring()
	_build_repel_area()
	_setup_audio()
	_find_world_environment()

func _find_world_environment() -> void:
	var root = get_tree().current_scene if get_tree() else null
	if root:
		_world_env = root.find_child("WorldEnvironment", true, false) as WorldEnvironment
		if _world_env and _world_env.environment:
			_orig_fog_density = _world_env.environment.volumetric_fog_density
			_orig_fog_color = _world_env.environment.volumetric_fog_albedo

func _restore_world_environment() -> void:
	if _world_env and is_instance_valid(_world_env) and _world_env.environment and is_instance_valid(_world_env.environment):
		_world_env.environment.volumetric_fog_density = _orig_fog_density
		_world_env.environment.volumetric_fog_albedo = _orig_fog_color

func setup(center_pos: Vector3, custom_radius: float = 17.5) -> void:
	global_position = center_pos
	radius = custom_radius
	_rebuild_all()

func _rebuild_all() -> void:
	if _fog_volume:
		_fog_volume.queue_free()
		_fog_volume = null
	if _particles:
		_particles.queue_free()
		_particles = null
	if _static_body:
		_static_body.queue_free()
		_static_body = null
	if _repel_area:
		_repel_area.queue_free()
		_repel_area = null
	_collision_shapes.clear()

	_build_volumetric_fog()
	_build_particles()
	_build_collision_ring()
	_build_repel_area()

func _build_volumetric_fog() -> void:
	var shader = load("res://components/world/circular_fog_wall.gdshader") as Shader
	if not shader:
		push_warning("CircularFogWall: No se pudo cargar circular_fog_wall.gdshader")
		return

	_fog_material = ShaderMaterial.new()
	_fog_material.shader = shader
	_fog_material.set_shader_parameter("radius", radius)
	_fog_material.set_shader_parameter("thickness", fog_thickness)
	_fog_material.set_shader_parameter("max_density", max_fog_density)
	_fog_material.set_shader_parameter("fade_progress", fade_amount)
	_fog_material.set_shader_parameter("fog_albedo", Color(0.62, 0.65, 0.70))
	_fog_material.set_shader_parameter("fog_emission", Color(0.04, 0.05, 0.06))

	_fog_volume = FogVolume.new()
	_fog_volume.name = "VolumetricFogRing"
	_fog_volume.shape = RenderingServer.FOG_VOLUME_SHAPE_BOX
	var box_span: float = (radius + fog_thickness + 3.0) * 2.0
	_fog_volume.size = Vector3(box_span, wall_height, box_span)
	_fog_volume.material = _fog_material
	_fog_volume.position = Vector3(0, wall_height * 0.45, 0)
	add_child(_fog_volume)

func _build_particles() -> void:
	_particles = GPUParticles3D.new()
	_particles.name = "FogSwirlParticles"
	_particles.amount = 72
	_particles.lifetime = 4.0
	_particles.preprocess = 1.0
	_particles.explosiveness = 0.0
	_particles.randomness = 0.5
	_particles.emitting = false

	var proc_mat = ParticleProcessMaterial.new()
	proc_mat.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_RING
	proc_mat.emission_ring_radius = radius
	proc_mat.emission_ring_inner_radius = maxf(1.0, radius - (fog_thickness * 0.5))
	proc_mat.emission_ring_height = 2.0
	proc_mat.emission_ring_axis = Vector3(0, 1, 0)
	proc_mat.direction = Vector3(0, 1, 0)
	proc_mat.spread = 25.0
	proc_mat.initial_velocity_min = 0.2
	proc_mat.initial_velocity_max = 0.8
	proc_mat.gravity = Vector3(0, 0.15, 0)
	proc_mat.angle_min = 0.0
	proc_mat.angle_max = 360.0
	proc_mat.scale_min = 4.0
	proc_mat.scale_max = 7.5

	# Fading de color y transparencia para que las nubes se desvanezcan suavemente
	var grad = Gradient.new()
	grad.offsets = PackedFloat32Array([0.0, 0.2, 0.75, 1.0])
	grad.colors = PackedColorArray([
		Color(0.65, 0.68, 0.73, 0.0),
		Color(0.65, 0.68, 0.73, 0.35),
		Color(0.55, 0.58, 0.64, 0.25),
		Color(0.45, 0.48, 0.55, 0.0)
	])
	var grad_tex = GradientTexture1D.new()
	grad_tex.gradient = grad
	proc_mat.color_ramp = grad_tex

	_particles.process_material = proc_mat

	# Textura radial suave para que no haya bordes poligonales
	var smoke_grad = Gradient.new()
	smoke_grad.offsets = PackedFloat32Array([0.0, 0.45, 1.0])
	smoke_grad.colors = PackedColorArray([
		Color(1, 1, 1, 1),
		Color(1, 1, 1, 0.4),
		Color(1, 1, 1, 0.0)
	])
	var smoke_tex = GradientTexture2D.new()
	smoke_tex.gradient = smoke_grad
	smoke_tex.fill = GradientTexture2D.FILL_RADIAL
	smoke_tex.fill_from = Vector2(0.5, 0.5)
	smoke_tex.fill_to = Vector2(0.5, 0.0)
	smoke_tex.width = 64
	smoke_tex.height = 64

	var draw_mat = StandardMaterial3D.new()
	draw_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	draw_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	draw_mat.vertex_color_use_as_albedo = true
	draw_mat.albedo_texture = smoke_tex
	draw_mat.billboard_mode = BaseMaterial3D.BILLBOARD_PARTICLES
	draw_mat.billboard_keep_scale = true
	draw_mat.proximity_fade_enabled = true
	draw_mat.proximity_fade_distance = 2.0

	var quad = QuadMesh.new()
	quad.size = Vector2(6.0, 6.0)
	quad.material = draw_mat
	_particles.draw_pass_1 = quad

	_particles.position = Vector3(0, 1.0, 0)
	add_child(_particles)

func _build_collision_ring() -> void:
	_static_body = StaticBody3D.new()
	_static_body.name = "FogCollisionRing"
	_static_body.collision_layer = 1
	_static_body.collision_mask = 0
	add_child(_static_body)

	var segments: int = 32
	var angle_step: float = TAU / float(segments)
	var chord: float = 2.0 * radius * sin(angle_step * 0.5)
	var thickness: float = 1.5

	for i in range(segments):
		var angle = float(i) * angle_step
		var pos = Vector3(cos(angle) * radius, (wall_height * 0.5) - 2.0, sin(angle) * radius)

		var box = BoxShape3D.new()
		box.size = Vector3(chord + 0.4, wall_height, thickness)

		var col = CollisionShape3D.new()
		col.name = "Segment_%d" % i
		col.shape = box
		col.position = pos
		col.rotation.y = -angle + (PI * 0.5)

		_static_body.add_child(col)
		_collision_shapes.append(col)

func _build_repel_area() -> void:
	_repel_area = Area3D.new()
	_repel_area.name = "FogRepelArea"
	_repel_area.collision_layer = 0
	_repel_area.collision_mask = 4 # Jugador

	var segments: int = 24
	var angle_step: float = TAU / float(segments)
	var chord: float = 2.0 * (radius - 1.0) * sin(angle_step * 0.5)

	for i in range(segments):
		var angle = float(i) * angle_step
		var pos = Vector3(cos(angle) * (radius - 1.0), (wall_height * 0.5) - 2.0, sin(angle) * (radius - 1.0))

		var box = BoxShape3D.new()
		box.size = Vector3(chord + 0.5, wall_height, 2.5)

		var col = CollisionShape3D.new()
		col.shape = box
		col.position = pos
		col.rotation.y = -angle + (PI * 0.5)
		_repel_area.add_child(col)

	_repel_area.body_entered.connect(_on_repel_area_entered)
	_repel_area.body_exited.connect(_on_repel_area_exited)
	add_child(_repel_area)

func _physics_process(_delta: float) -> void:
	if not is_active or is_dissolving:
		return
	if _player_in_fog and is_instance_valid(_player_in_fog):
		# Empujar suavemente hacia el centro de la arena para que la niebla lo rechace
		var to_center = (global_position - _player_in_fog.global_position)
		to_center.y = 0.0
		if to_center.length_squared() > 0.01:
			_player_in_fog.velocity += to_center.normalized() * 3.5

func _on_repel_area_entered(body: Node3D) -> void:
	if body.is_in_group("player") and body is CharacterBody3D:
		_player_in_fog = body as CharacterBody3D

func _on_repel_area_exited(body: Node3D) -> void:
	if body == _player_in_fog:
		_player_in_fog = null

func _setup_audio() -> void:
	_audio_player = AudioStreamPlayer.new()
	_audio_player.name = "RingingAudio"
	var sfx = load("res://assets/audio/ringing.wav") as AudioStream
	if sfx:
		_audio_player.stream = sfx
		_audio_player.volume_db = -6.0
	add_child(_audio_player)

func _update_fog_volume(val: float) -> void:
	if _fog_material:
		_fog_material.set_shader_parameter("fade_progress", val)

func activate() -> void:
	if is_active:
		return
	is_active = true
	is_dissolving = false

	for col in _collision_shapes:
		if is_instance_valid(col):
			col.disabled = false

	# Encender emisión de partículas de niebla
	if _particles:
		_particles.emitting = true

	# Animar densidad de la niebla volumétrica
	var tween = create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "fade_amount", 1.0, fade_in_time)

	# Sonido agudo
	if _audio_player and _audio_player.stream:
		_audio_player.volume_db = -6.0
		_audio_player.play()

	# Mensaje narrativo si es la primera vez
	if not has_experienced_fog_encounter:
		has_experienced_fog_encounter = true
		if has_node("/root/Globals"):
			Globals.show_announcement("Antonio: ¿Qué me está pasando...?", 4.0)

	# Intensificar niebla del entorno durante la batalla
	if _world_env and _world_env.environment:
		if _env_tweener:
			_env_tweener.kill()
		_env_tweener = create_tween().set_parallel(true).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
		_env_tweener.tween_property(_world_env.environment, "volumetric_fog_density", 0.12, fade_in_time * 1.5)
		_env_tweener.tween_property(_world_env.environment, "volumetric_fog_albedo", Color(0.40, 0.38, 0.45), fade_in_time * 1.5)

func dissolve() -> void:
	if is_dissolving or not is_active:
		return
	is_dissolving = true
	is_active = false
	_player_in_fog = null

	for col in _collision_shapes:
		if is_instance_valid(col):
			col.set_deferred("disabled", true)

	if _repel_area:
		_repel_area.monitoring = false

	if _particles:
		_particles.emitting = false

	if _audio_player and _audio_player.playing:
		var sound_tween = create_tween()
		sound_tween.tween_property(_audio_player, "volume_db", -50.0, 1.5)
		sound_tween.tween_callback(Callable(_audio_player, "stop"))

	if _world_env and _world_env.environment:
		if _env_tweener:
			_env_tweener.kill()
		_env_tweener = create_tween().set_parallel(true).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		_env_tweener.tween_property(_world_env.environment, "volumetric_fog_density", _orig_fog_density, fade_out_time)
		_env_tweener.tween_property(_world_env.environment, "volumetric_fog_albedo", _orig_fog_color, fade_out_time)

	var tween = create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	tween.tween_property(self, "fade_amount", 0.0, fade_out_time)
	tween.tween_callback(Callable(self, "queue_free"))
