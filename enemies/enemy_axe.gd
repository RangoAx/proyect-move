extends Enemy
class_name AxeEnemy

@export var axe_count: int = 1
@export var throw_cooldown: float = 3.0
@export var thrown_axe_damage: float = 20.0 

var _throw_timer: float = 0.0

const axe_scene = preload("res://interactuables/weapons/throwable_axe.tscn")

func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	_throw_timer -= delta

func throw_axe():
	if _throw_timer > 0:
		return
	var axe: RigidBody3D = axe_scene.instantiate()
	axe.thrower = self
	axe.damage = thrown_axe_damage
	
	var offset = Vector3(0.7, 1.5, 0)
	get_parent().add_child(axe)
	axe.global_position = global_position + offset.rotated(Vector3(0, 1, 0), rotation.y)
	axe.rotation.y = rotation.y
	var spawn_pos = axe.global_position
	var target_pos = player.global_position + Vector3(0, 2, 0)
	var dir = spawn_pos.direction_to(target_pos)
	axe.call_deferred("apply_central_impulse", dir * 16)
	axe.call_deferred("apply_torque", Vector3(-20, 0, 0).rotated(Vector3(0, 1, 0), rotation.y))
	#axe_count -= 1
	_throw_timer = throw_cooldown
