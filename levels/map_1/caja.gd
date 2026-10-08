extends Node3D
class_name Caja
@export var fragmentos : int

const fragmento_escena = preload("res://components/fragmento.tscn")
func _on_caja_hitbox_area_entered(_area: Area3D) -> void:
	for i in range(fragmentos):
		var fragmento_nuevo : RigidBody3D = fragmento_escena.instantiate()
		get_parent().add_child(fragmento_nuevo)
		fragmento_nuevo.global_position = global_position
		fragmento_nuevo.apply_central_impulse(Vector3(randf_range(-1,1),2,randf_range(-1,1)))
	queue_free()
