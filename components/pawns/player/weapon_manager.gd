extends Node
class_name WeaponManager

@onready var movement = $"../Movement"
var weapon : StringName = "Sword"
var is_attacking : bool = false

func _input(_event):
	
	if Input.is_action_just_released("aim"):
		get_weapon().aim_end()
		movement.is_aiming = false
	
	if not movement.is_dashing:
		if Input.is_action_just_pressed("aim"):
			get_weapon().aim_start()
			movement.is_aiming = true
		if Input.is_action_just_pressed("attack") and movement.is_aiming:
			get_weapon().aim_attack()
		if Input.is_action_just_pressed("attack") and not is_attacking:
			is_attacking = true
			await get_weapon().attack()
			is_attacking = false
	
	# weapon switching
	if not movement.is_aiming and not is_attacking:
		if Input.is_action_just_pressed("weapon_1"):
			weapon = "Sword"
			%"Cuchillo loco".visible = true
			%hacha1.visible = false
			Globals.weapon_swapped.emit("Cuchillo")
		elif Input.is_action_just_pressed("weapon_2"):
			weapon = "Axe"
			%hacha1.visible = true
			%"Cuchillo loco".visible = false
			Globals.weapon_swapped.emit("Hacha")

func get_weapon() -> Weapon:
	return get_node(str(weapon))
