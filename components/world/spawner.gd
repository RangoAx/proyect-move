extends Area3D
class_name Spawner

@export var spawn_points: Array[Marker3D] = []
@export var waves: Array[PackedStringArray] = []

var current_wave: int = 0

const ENEMY_SCENES: Dictionary = {
	"enemy_axe": preload("res://enemies/enemy_axe.tscn"),
	"enemy_fist": preload("res://enemies/enemy_fist.tscn"),
	"enemy_lumberjack": preload("res://enemies/enemy_lumberjack.tscn"),
}

func is_wave_finished() -> bool:
	for child in get_children():
		if child is Enemy:
			return false
	return true

func _on_body_entered(body: Node3D = null) -> void:
	if body and not body.is_in_group("player"):
		return
	if not is_wave_finished():
		return
	if current_wave >= waves.size():
		return
	if spawn_points.is_empty():
		push_warning("Spawner: No spawn points configured.")
		return

	var wave_enemies := waves[current_wave]
	current_wave += 1

	for enemy_key in wave_enemies:
		if not ENEMY_SCENES.has(enemy_key):
			push_error("Spawner: Unknown enemy key: %s" % enemy_key)
			continue

		var enemy_scene: PackedScene = ENEMY_SCENES[enemy_key]
		var enemy_node: Node3D = enemy_scene.instantiate()

		add_child(enemy_node)

		var spawn_point: Marker3D = spawn_points.pick_random()
		enemy_node.global_position = spawn_point.global_position
		enemy_node.tree_exiting.connect(_on_enemy_tree_exiting)

func _on_enemy_tree_exiting() -> void:
	# Small delay or call_deferred so current enemy is freed before checking wave status
	call_deferred("_check_next_wave")

func _check_next_wave() -> void:
	if is_wave_finished():
		_on_body_entered()
