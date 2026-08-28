extends Weapon

@export var thrown_axe_damage: float = 25.0

func aim_start():
	camera.expected_length = 1
	camera.expected_offset = Vector2(1, 0.4)

func aim_attack():
	if player.axe_amount > 0:
		create_thrown_axe()

const axe_scene = preload("res://interactuables/weapons/throwable_axe.tscn")

func create_thrown_axe():
	var axe : RigidBody3D = axe_scene.instantiate()
	
	axe.thrower = player
	axe.damage = thrown_axe_damage
	var offset = Vector3(0.7, 1.5, 0)
	var spring = player.camera.spring
	get_parent().add_child(axe)
	axe.global_position = player.global_position + offset.rotated(Vector3(0,1,0),spring.rotation.y)
	axe.rotation.y = spring.rotation.y
	axe.apply_central_impulse(Vector3(0, 1, -15).rotated(Vector3(1, 0, 0),spring.rotation.x).rotated(Vector3(0, 1, 0),spring.rotation.y - 0.05))
	axe.apply_torque(Vector3(-20, 0, 0).rotated(Vector3(0, 1, 0),spring.rotation.y))
	
	player.axe_amount -= 1
