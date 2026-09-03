extends Area3D


func _on_body_entered(_body: Node3D) -> void:
	Globals.add_fragments(1)
	get_parent().queue_free()

func _physics_process(delta: float) -> void:
	var rigid_body : RigidBody3D = get_parent()
	rigid_body.constant_force = global_position.direction_to(Globals.player.global_position) * 10
