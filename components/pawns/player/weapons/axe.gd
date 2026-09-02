extends Weapon

@export var thrown_axe_damage: float = 25.0

var recharge_timer: float = 0.0

const axe_scene = preload("res://interactuables/weapons/throwable_axe.tscn")

func get_cooldown() -> float:
	if Globals.axe_level >= 2:
		return 3.0 # Nivel 2: Reducción de enfriamiento a 3 segundos
	return 6.0 # Base: 6 segundos de cooldown

func get_max_axes() -> int:
	if Globals.axe_level >= 3:
		return 3 # Nivel 3: Expansión de inventario a 3 hachas
	return 1 # Base y Nivel 2: Capacidad de 1 hacha

func _ready():
	if player and "axe_amount" in player:
		player.axe_amount = get_max_axes()

func _process(delta: float):
	# Recarga automática con el paso del tiempo
	if player.axe_amount < get_max_axes():
		recharge_timer -= delta
		if recharge_timer <= 0.0:
			player.axe_amount += 1
			# Si todavía faltan hachas por recargar, reinicia el ciclo
			if player.axe_amount < get_max_axes():
				recharge_timer = get_cooldown()
			else:
				recharge_timer = 0.0

func aim_start():
	camera.expected_length = 1
	camera.expected_offset = Vector2(1, 0.4)

func aim_attack():
	if player.axe_amount > 0:
		create_thrown_axe()

func create_thrown_axe():
	var axe : RigidBody3D = axe_scene.instantiate()
	
	axe.thrower = player
	axe.damage = thrown_axe_damage
	var offset = Vector3(0.7, 1.5, 0)
	var spring = player.camera.spring
	get_parent().add_child(axe)
	axe.global_position = player.global_position + offset.rotated(Vector3(0, 1, 0), spring.rotation.y)
	axe.rotation.y = spring.rotation.y
	axe.apply_central_impulse(Vector3(0, 1, -15).rotated(Vector3(1, 0, 0), spring.rotation.x).rotated(Vector3(0, 1, 0), spring.rotation.y - 0.05))
	axe.apply_torque(Vector3(-20, 0, 0).rotated(Vector3(0, 1, 0), spring.rotation.y))
	
	player.axe_amount -= 1
	
	# Inicia el ciclo de recarga si no estaba activo
	if recharge_timer <= 0.0:
		recharge_timer = get_cooldown()
