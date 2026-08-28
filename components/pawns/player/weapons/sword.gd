extends Weapon
class_name SwordWeapon

@export var sword_area : Area3D
var enemies_hit = []

func _ready():
	sword_area.monitoring = false
	if not sword_area.body_entered.is_connected(_on_body_entered):
		sword_area.body_entered.connect(_on_body_entered)


func hitbox_open():
	enemies_hit.clear() 
	sword_area.set_deferred("monitoring", true)

func hitbox_close():
	sword_area.set_deferred("monitoring", false)

func attack():
	if await play_interruptible_animation("Ataque1", 0.2):
		pass
	else:
		if await play_interruptible_animation("Ataque2", 0.2):
			pass
		else:
			await play_interruptible_animation("Ataque3", 0.2)
			
	end()

func _on_body_entered(body : Node3D):
	if body is NPC:
		if body in enemies_hit:
			return
		enemies_hit.append(body)
		body.take_damage(20, player.global_position)

func end():
	sword_area.set_deferred("monitoring", false)
