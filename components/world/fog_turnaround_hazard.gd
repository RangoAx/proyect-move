extends Area3D
class_name FogTurnaroundHazard

@export var damage_per_sec: float = 18.0
var _player_inside: bool = false
var _damage_timer: float = 0.0

var _world_env: WorldEnvironment = null
var _default_fog_density: float = 0.04
var _default_fog_color: Color = Color(1.0, 1.0, 1.0)

func _ready() -> void:
	collision_layer = 0
	collision_mask = 4 # Capa 4: Jugador
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	
	var root = get_tree().current_scene if get_tree() else null
	if root:
		_world_env = root.find_child("WorldEnvironment", true, false) as WorldEnvironment
		if _world_env and _world_env.environment:
			_default_fog_density = _world_env.environment.volumetric_fog_density
			_default_fog_color = _world_env.environment.volumetric_fog_albedo

func _physics_process(delta: float) -> void:
	if not _player_inside:
		return
		
	_damage_timer += delta
	if _damage_timer >= 1.0:
		_damage_timer = 0.0
		if Globals.player and Globals.player.has_method("take_damage"):
			Globals.player.take_damage(damage_per_sec)

func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		_player_inside = true
		_damage_timer = 0.0
		Globals.show_announcement("Antonio: La niebla me asfixia... No puedo escapar por aquí.", 3.5)
		
		# Aumentar densidad y oscurecer niebla
		if _world_env and _world_env.environment:
			var tween = create_tween().set_parallel(true)
			tween.tween_property(_world_env.environment, "volumetric_fog_density", 0.35, 1.5)
			tween.tween_property(_world_env.environment, "volumetric_fog_albedo", Color(0.15, 0.12, 0.15), 1.5)

func _on_body_exited(body: Node3D) -> void:
	if body.is_in_group("player"):
		_player_inside = false
		_damage_timer = 0.0
		
		# Restaurar niebla normal al volver al camino
		if _world_env and _world_env.environment:
			var tween = create_tween().set_parallel(true)
			tween.tween_property(_world_env.environment, "volumetric_fog_density", _default_fog_density, 2.0)
			tween.tween_property(_world_env.environment, "volumetric_fog_albedo", _default_fog_color, 2.0)

