extends Area3D
class_name ZoneSpawner

signal zone_activated
signal zone_cleared

@export_group("Configuración de Zona")
@export var zone_name: String = "Zona"
## Escenas de enemigos que se spawnearán exactamente en esta zona
@export var enemy_scenes: Array[PackedScene] = []
## Si es false (como en el tutorial), la zona no vuelve a spawnear enemigos tras derrotarlos a todos
@export var can_respawn: bool = true
## Tiempo de espera en segundos tras vencer a TODOS los enemigos antes de que reaparezcan
@export var respawn_delay: float = 10.0
## Si es true, la reaparición prioriza los puntos situados a las espaldas del jugador
@export var spawn_behind_player: bool = true
## Si es true, la zona se activa inmediatamente al iniciar la escena en vez de esperar al Area3D
@export var auto_spawn_on_start: bool = false
## Si es true, la zona requiere que el jugador tenga la llave de la iglesia para activarse
@export var requires_church_key: bool = false

var _spawn_points: Array[Marker3D] = []
var _alive_enemies: Array[Node3D] = []
var _is_active: bool = false
var _is_cleared: bool = false
var _is_respawning: bool = false

func _ready() -> void:
	# Configurar colisiones para detectar solo al jugador (layer 4)
	collision_layer = 0
	collision_mask = 4

	# Encontrar todos los Marker3D que sean hijos
	for child in get_children():
		if child is Marker3D:
			_spawn_points.append(child)

	body_entered.connect(_on_player_entered)

	if auto_spawn_on_start:
		_start_zone_deferred()

func _start_zone_deferred() -> void:
	await get_tree().physics_frame
	_start_zone()

func _process(_delta: float) -> void:
	if requires_church_key and not _is_active and not _is_cleared and not _is_respawning:
		if has_node("/root/Globals") and Globals.has_church_key:
			for body in get_overlapping_bodies():
				if body.is_in_group("player"):
					_start_zone()
					break

func _on_player_entered(body: Node3D) -> void:
	if _is_cleared or _is_active or _is_respawning:
		return
	if requires_church_key:
		if not has_node("/root/Globals") or not Globals.has_church_key:
			return
	if body.is_in_group("player"):
		_start_zone()

func _start_zone() -> void:
	if _is_cleared or _is_active:
		return
	_is_active = true
	zone_activated.emit()
	_spawn_wave(false)

func _get_player() -> Node3D:
	if has_node("/root/Globals"):
		var g = get_node("/root/Globals")
		if "player" in g and g.player:
			return g.player
	if get_tree():
		var players = get_tree().get_nodes_in_group("player")
		if not players.is_empty():
			return players[0] as Node3D
	return null

func _spawn_wave(is_respawn: bool) -> void:
	if _is_cleared:
		return
	if enemy_scenes.is_empty():
		push_warning("ZoneSpawner '%s': No hay enemy_scenes asignadas." % zone_name)
		return
	if _spawn_points.is_empty():
		push_warning("ZoneSpawner '%s': No tiene Marker3D de spawn." % zone_name)
		return

	# Comprobaciones de seguridad
	if not is_inside_tree() or get_tree() == null:
		return
	var player = _get_player()
	if player and "is_dead" in player and player.is_dead:
		return

	var scene_root: Node = get_tree().current_scene if (get_tree() and get_tree().current_scene) else (owner if owner else self)
	var nav_map = get_world_3d().navigation_map if get_world_3d() else RID()

	# Usar una copia de markers para distribuir enemigos si hay suficientes
	var available_markers: Array[Marker3D] = _spawn_points.duplicate()
	if not is_respawn:
		available_markers.shuffle()

	for enemy_scene in enemy_scenes:
		if not enemy_scene:
			continue

		var enemy = enemy_scene.instantiate() as Node3D
		if not enemy:
			continue

		# Seleccionar posición de spawn fuera de la vista directa del jugador
		var spawn_pos: Vector3
		if auto_spawn_on_start and not is_respawn:
			# Para zonas iniciales del tutorial que inician con el nivel
			if not available_markers.is_empty():
				spawn_pos = available_markers.pop_back().global_position
			else:
				spawn_pos = _spawn_points.pick_random().global_position
		else:
			# Combate dinámico: NUNCA spawnear a la vista directa del jugador
			spawn_pos = _get_stealth_spawn_point(player, available_markers)

		# Ajustar al NavigationMesh para garantizar que esté perfectamente apoyado
		if nav_map.is_valid() and NavigationServer3D.map_get_iteration_id(nav_map) > 0:
			var safe_pos = NavigationServer3D.map_get_closest_point(nav_map, spawn_pos)
			if safe_pos.distance_to(spawn_pos) < 5.0:
				spawn_pos = safe_pos

		enemy.tree_exited.connect(_on_enemy_tree_exited.bind(enemy))

		scene_root.add_child(enemy)
		enemy.global_position = spawn_pos

		# Las oleadas (zonas activas de combate o reapariciones tras oleadas) detectan al jugador automáticamente
		if is_respawn or not auto_spawn_on_start:
			if "is_aware" in enemy:
				enemy.is_aware = true
			if "ai_enabled" in enemy:
				enemy.ai_enabled = true

		_alive_enemies.append(enemy)

func _get_stealth_spawn_point(player: Node3D, available_markers: Array[Marker3D]) -> Vector3:
	if _spawn_points.is_empty():
		return global_position

	var candidate_pool: Array[Marker3D] = available_markers if not available_markers.is_empty() else _spawn_points
	if not player or not is_inside_tree():
		return candidate_pool.pick_random().global_position

	var camera = get_viewport().get_camera_3d() if get_viewport() else null
	var space_state = get_world_3d().direct_space_state if get_world_3d() else null
	var player_pos: Vector3 = player.global_position

	# Clasificar markers:
	# Tier 1: Ocultos a la vista (fuera de frustum o tras muros/casas) y a distancia cercana/media (6m - 28m)
	# Tier 2: Ocultos a la vista a cualquier distancia válida (> 4m)
	# Tier 3: Visibles pero a mayor distancia del jugador
	var tier1: Array[Marker3D] = []
	var tier2: Array[Marker3D] = []
	var tier3: Array[Marker3D] = []

	for marker in candidate_pool:
		var m_pos = marker.global_position
		var dist = player_pos.distance_to(m_pos)
		if dist < 4.0:
			continue # Demasiado pegado al jugador

		var is_visible_to_player: bool = false
		if camera:
			var head_target = m_pos + Vector3(0, 1.4, 0)
			if camera.is_position_in_frustum(head_target):
				if space_state:
					# Raycast para comprobar si hay un muro, casa o colina tapando la visión
					var ray_query = PhysicsRayQueryParameters3D.create(camera.global_position, head_target, 1)
					var hit = space_state.intersect_ray(ray_query)
					if hit.is_empty():
						is_visible_to_player = true # El jugador lo ve directamente sin obstáculos
					else:
						is_visible_to_player = false # Hay un obstáculo bloqueando la visión (está oculto)
				else:
					is_visible_to_player = true
			else:
				is_visible_to_player = false # Fuera del cono de visión de la cámara (a las espaldas o lateral)
		else:
			# Fallback a dirección del jugador si no hay cámara activa
			var fwd = -player.global_transform.basis.z
			var dir = (m_pos - player_pos).normalized()
			is_visible_to_player = fwd.dot(dir) > 0.1

		if not is_visible_to_player:
			if dist >= 6.0 and dist <= 28.0:
				tier1.append(marker)
			else:
				tier2.append(marker)
		else:
			tier3.append(marker)

	var selected_marker: Marker3D = null
	if not tier1.is_empty():
		selected_marker = tier1.pick_random()
	elif not tier2.is_empty():
		selected_marker = tier2.pick_random()
	elif not tier3.is_empty():
		tier3.sort_custom(func(a, b): return player_pos.distance_squared_to(a.global_position) > player_pos.distance_squared_to(b.global_position))
		selected_marker = tier3[0]
	else:
		selected_marker = candidate_pool.pick_random()

	if available_markers.has(selected_marker):
		available_markers.erase(selected_marker)

	return selected_marker.global_position

func _on_enemy_tree_exited(enemy: Node3D) -> void:
	_alive_enemies.erase(enemy)

	if _alive_enemies.is_empty():
		if not can_respawn:
			_is_cleared = true
			_is_active = false
			zone_cleared.emit()
		else:
			_is_respawning = true
			if not is_inside_tree() or get_tree() == null:
				return
			# Esperar 10 segundos según GDD
			await get_tree().create_timer(respawn_delay).timeout
			if not is_inside_tree() or get_tree() == null:
				return
			_is_respawning = false

			# Verificar si el jugador sigue vivo y la escena existe
			if not is_inside_tree() or get_tree() == null:
				return
			var player = _get_player()
			if player and "is_dead" in player and player.is_dead:
				return

			_spawn_wave(true)
