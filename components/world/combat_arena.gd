extends Area3D
class_name CombatArena

signal arena_started
signal arena_cleared

enum TriggerType {
	ON_ENTER,
	ON_AXE,
	ON_KEY_TO_CHURCH
}

@export_group("Arena Settings")
@export var arena_name: String = "Punto de Pelea"
@export var trigger_type: TriggerType = TriggerType.ON_ENTER
@export var enemy_scenes: Array[PackedScene] = []
## Rutas (NodePath) a los Marker3D de las puertas de cabaña (spawn de enemigos)
@export var door_cabin_marker_paths: Array[NodePath] = []
## Rutas (NodePath) a los Marker3D en la niebla (spawn alternativo)
@export var fog_marker_paths: Array[NodePath] = []

@export_group("Lockdown Barriers")
## Rutas (NodePath) a los nodos barricada que bloquean las salidas del arena
@export var barrier_node_paths: Array[NodePath] = []

@export_group("Audio & Effects")
@export var ringing_sound: AudioStream = preload("res://assets/audio/ringing.wav")
@export var fog_dense_density: float = 0.16
@export var fog_dense_color: Color = Color(0.28, 0.25, 0.32)

var _is_triggered: bool = false
var _is_cleared: bool = false
var _alive_enemies: Array[Node3D] = []
var _audio_player: AudioStreamPlayer = null
var _world_env: WorldEnvironment = null
var _dir_light: DirectionalLight3D = null

# Arrays resueltos en _ready() desde los NodePath exportados
var _door_markers: Array[Marker3D] = []
var _fog_markers: Array[Marker3D] = []
var _barriers: Array[Node3D] = []

var _default_fog_density: float = 0.04
var _default_fog_color: Color = Color(1.0, 1.0, 1.0)
var _default_light_energy: float = 1.0

func _ready() -> void:
	collision_layer = 0
	collision_mask = 4 # Detecta al jugador (layer 4)
	
	# Resolver NodePaths a nodos reales
	for p in door_cabin_marker_paths:
		var n = get_node_or_null(p)
		if n is Marker3D:
			_door_markers.append(n as Marker3D)
	for p in fog_marker_paths:
		var n = get_node_or_null(p)
		if n is Marker3D:
			_fog_markers.append(n as Marker3D)
	for p in barrier_node_paths:
		var n = get_node_or_null(p)
		if n is Node3D:
			_barriers.append(n as Node3D)
	
	_setup_audio()
	_setup_barriers(false) # Barreras inactivas al inicio
	
	# Localizar WorldEnvironment y DirectionalLight3D
	_find_environment_nodes()
	
	# Conexión para entrada física
	body_entered.connect(_on_body_entered)
	
	# Conexiones para triggers basados en eventos
	if trigger_type == TriggerType.ON_AXE:
		Globals.axe_acquired.connect(_on_axe_acquired)
	elif trigger_type == TriggerType.ON_KEY_TO_CHURCH:
		Globals.church_key_acquired.connect(_on_key_acquired)

func _find_environment_nodes() -> void:
	var tree = get_tree()
	if not tree:
		return
	var root = tree.current_scene
	if not root:
		return
	
	_world_env = root.find_child("WorldEnvironment", true, false) as WorldEnvironment
	if _world_env and _world_env.environment:
		_default_fog_density = _world_env.environment.volumetric_fog_density
		_default_fog_color = _world_env.environment.volumetric_fog_albedo
		
	_dir_light = root.find_child("DirectionalLight3D", true, false) as DirectionalLight3D
	if _dir_light:
		_default_light_energy = _dir_light.light_energy

func _setup_audio() -> void:
	_audio_player = AudioStreamPlayer.new()
	if ringing_sound:
		if ringing_sound is AudioStreamWAV:
			(ringing_sound as AudioStreamWAV).loop_mode = AudioStreamWAV.LOOP_FORWARD
		_audio_player.stream = ringing_sound
	_audio_player.bus = "Master"
	_audio_player.volume_db = -40.0
	add_child(_audio_player)

func _setup_barriers(active: bool) -> void:
	for barrier in _barriers:
		if not is_instance_valid(barrier):
			continue
		barrier.visible = active
		# Activar o desactivar colisión de cualquier CollisionShape3D o CollisionPolygon3D
		_set_collision_recursive(barrier, active)

func _set_collision_recursive(node: Node, enabled: bool) -> void:
	if node is CollisionShape3D or node is CollisionPolygon3D:
		node.set_deferred("disabled", not enabled)
	for child in node.get_children():
		_set_collision_recursive(child, enabled)

func _on_body_entered(body: Node3D) -> void:
	if _is_triggered or _is_cleared:
		return
	if not body.is_in_group("player"):
		return
		
	if trigger_type == TriggerType.ON_ENTER:
		start_arena()
	elif trigger_type == TriggerType.ON_KEY_TO_CHURCH and Globals.has_church_key:
		start_arena()

func _on_axe_acquired() -> void:
	if _is_triggered or _is_cleared:
		return
	# Si el trigger es por conseguir el hacha, se inicia la pelea inmediatamente
	if trigger_type == TriggerType.ON_AXE:
		start_arena()

func _on_key_acquired() -> void:
	# La arena hacia la iglesia se activará cuando el jugador con la llave entre a la zona
	pass

func start_arena() -> void:
	if _is_triggered or _is_cleared:
		return
	_is_triggered = true
	arena_started.emit()
	
	# 1. Bloqueo de escapes (barreras físicas y visuales)
	_setup_barriers(true)
	
	# 2. Pitido agudo (ringing audio con fundido tenso de entrada)
	if _audio_player and _audio_player.stream:
		_audio_player.play()
		var tween_audio = create_tween()
		tween_audio.tween_property(_audio_player, "volume_db", -4.0, 1.2)
		
	# 3. La niebla se hace más densa y un poco más oscura
	_transition_fog(true)
	
	# 4. Primer pensamiento de Antonio ("¿Qué me está pasando...?")
	if not Globals.has_experienced_fog_ringing:
		Globals.has_experienced_fog_ringing = true
		Globals.show_announcement("Antonio: ¿Qué me está pasando...?", 4.5)
		
	# 5. Spawn de enemigos en cabañas o saliendo de la densa niebla
	_spawn_arena_enemies()

func _transition_fog(to_dark: bool) -> void:
	if not _world_env or not _world_env.environment:
		_find_environment_nodes()
	if not _world_env or not _world_env.environment:
		return
		
	var env = _world_env.environment
	var target_density = fog_dense_density if to_dark else _default_fog_density
	var target_color = fog_dense_color if to_dark else _default_fog_color
	var target_light = (_default_light_energy * 0.4) if to_dark else _default_light_energy
	var dur = 2.0 if to_dark else 2.5
	
	var tween = create_tween().set_parallel(true)
	tween.tween_property(env, "volumetric_fog_density", target_density, dur).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(env, "volumetric_fog_albedo", target_color, dur).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	
	if _dir_light:
		tween.tween_property(_dir_light, "light_energy", target_light, dur).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

func _spawn_arena_enemies() -> void:
	if enemy_scenes.is_empty():
		return
		
	var scene_root: Node = get_tree().current_scene if (get_tree() and get_tree().current_scene) else self
	
	# Combinar puntos de cabañas y de niebla (ya resueltos en _ready)
	var spawn_pool: Array[Marker3D] = []
	spawn_pool.append_array(_door_markers)
	spawn_pool.append_array(_fog_markers)
	
	if spawn_pool.is_empty():
		# Fallback a la posición de la propia arena
		var fallback_marker = Marker3D.new()
		fallback_marker.position = Vector3(0, 0, 0)
		add_child(fallback_marker)
		spawn_pool.append(fallback_marker)
		
	var pool_copy = spawn_pool.duplicate()
	pool_copy.shuffle()
	
	for enemy_scene in enemy_scenes:
		if not enemy_scene:
			continue
			
		var enemy = enemy_scene.instantiate() as Node3D
		if not enemy:
			continue
			
		var marker: Marker3D = pool_copy.pop_back() if not pool_copy.is_empty() else spawn_pool.pick_random()
		var spawn_pos: Vector3 = marker.global_position
		
		# Ajustar al NavMesh si existe
		var nav_map = get_world_3d().navigation_map if get_world_3d() else RID()
		if nav_map.is_valid() and NavigationServer3D.map_get_iteration_id(nav_map) > 0:
			var safe_pos = NavigationServer3D.map_get_closest_point(nav_map, spawn_pos)
			if safe_pos.distance_to(spawn_pos) < 6.0:
				spawn_pos = safe_pos
				
		scene_root.add_child(enemy)
		enemy.global_position = spawn_pos
		
		# Habilitar persecución agresiva hacia el jugador
		if "is_aware" in enemy:
			enemy.is_aware = true
		if "ai_enabled" in enemy:
			enemy.ai_enabled = true
			
		enemy.tree_exited.connect(_on_enemy_killed.bind(enemy))
		_alive_enemies.append(enemy)

func _on_enemy_killed(enemy: Node3D) -> void:
	if enemy in _alive_enemies:
		_alive_enemies.erase(enemy)
		
	if _alive_enemies.is_empty() and _is_triggered and not _is_cleared:
		_clear_arena()

func _clear_arena() -> void:
	_is_cleared = true
	arena_cleared.emit()
	
	# 1. Quitar bloqueo de barreras
	_setup_barriers(false)
	
	# 2. Desvanecer pitido agudo
	if _audio_player and _audio_player.playing:
		var tween_audio = create_tween()
		tween_audio.tween_property(_audio_player, "volume_db", -40.0, 2.0)
		tween_audio.tween_callback(func():
			if is_instance_valid(_audio_player):
				_audio_player.stop()
		)
		
	# 3. Disipar niebla y devolver iluminación a la normalidad
	_transition_fog(false)

