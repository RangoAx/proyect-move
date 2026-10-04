extends Area3D
class_name ZoneSpawner

@export_group("Configuración de Oleadas")
@export var enemy_types: Array[PackedScene] # Arrastra aquí las escenas de tus enemigos
@export var max_concurrent: int = 5
@export var total_to_spawn: int = 20

var _spawn_points: Array[Marker3D] = []
var _is_active: bool = false
var _spawned_count: int = 0
var _alive_count: int = 0

func _ready() -> void:
	# Configurar colisiones para detectar solo al jugador
	collision_layer = 0
	collision_mask = 4 
	
	# Buscar automáticamente todos los Marker3D que pongas como hijos
	for child in get_children():
		if child is Marker3D:
			_spawn_points.append(child)
			
	body_entered.connect(_on_player_entered)

func _on_player_entered(body: Node3D) -> void:
	if body.is_in_group("player") and not _is_active and _spawned_count < total_to_spawn:
		_is_active = true
		_check_and_spawn()

func _check_and_spawn() -> void:
	if not _is_active: 
		return
	
	# --- SEGURO 1: Si el jugador está muerto, cortamos el ciclo ---
	if Globals.player and Globals.player.is_dead:
		return
		
	# --- SEGURO 2: Si la escena se está borrando/recargando, abortamos ---
	if not is_inside_tree() or get_tree() == null or get_tree().current_scene == null:
		return
	
	# Repone enemigos mientras haya espacio en pantalla (máx 5) y en la reserva (máx 30)
	while _alive_count < max_concurrent and _spawned_count < total_to_spawn:
		_spawn_enemy()

func _spawn_enemy() -> void:
	if enemy_types.is_empty() or _spawn_points.is_empty():
		push_error("El ZoneSpawner no tiene enemigos asignados o le faltan Marker3D.")
		return
		
	var random_scene = enemy_types.pick_random()
	var enemy = random_scene.instantiate() as Node3D
	
	var sp = _spawn_points.pick_random()
	enemy.global_position = sp.global_position
	
	enemy.tree_exited.connect(_on_enemy_died)
	
	# --- SEGURO 3: Verificación final justo antes de inyectarlo en el mapa ---
	if get_tree() and get_tree().current_scene:
		get_tree().current_scene.add_child(enemy)
		
		# Despertamos al enemigo al instante
		if "is_aware" in enemy: enemy.is_aware = true
		if "ai_enabled" in enemy: enemy.ai_enabled = true
		
		_alive_count += 1
		_spawned_count += 1
	else:
		# Si la escena ya no existe, eliminamos el modelo huérfano para evitar fugas de memoria
		enemy.queue_free()

func _on_enemy_died() -> void:
	_alive_count -= 1
	
	if _spawned_count >= total_to_spawn and _alive_count <= 0:
		_is_active = false
		# Aquí podrías llamar a Globals.set_objective("Zona despejada")
	else:
		# Apenas muere uno, intenta spawnear el siguiente para mantener siempre 5
		_check_and_spawn()
