extends Enemy
class_name FistEnemy


const axe_scene = preload("res://interactuables/weapons/throwable_axe.tscn")

func _physics_process(delta: float) -> void:
	super._physics_process(delta)

	var offset = Vector3(0.7, 1.5, 0)
	var target_pos = player.global_position + Vector3(0, 2, 0)
