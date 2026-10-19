extends Enemy
class_name PitchforkEnemy

func _physics_process(delta: float) -> void:
	super._physics_process(delta)

func animation_process(delta):
	if anim and not is_attacking:
		var horizontal_speed = Vector2(velocity.x, velocity.z).length()
		
		if hitstun_timer > 0:
			pass 
		elif horizontal_speed > 0.2:
			anim.play("Walk") 
		else:
			anim.play("Idle")
