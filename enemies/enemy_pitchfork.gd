extends Enemy
class_name PitchforkEnemy

func _ready() -> void:
	max_health = 100.0
	health = 100.0
	speed = 2.4
	if has_node("Enemigo trinche/AnimationPlayer"):
		anim = $"Enemigo trinche/AnimationPlayer" as AnimationPlayer
	super._ready()
	if life_bar:
		life_bar.max_value = max_health
		life_bar.value = health
	_update_hp_label()

func _physics_process(delta: float) -> void:
	super._physics_process(delta)

func animation_process(_delta: float) -> void:
	if anim and not is_attacking:
		var horizontal_speed := Vector2(velocity.x, velocity.z).length()
		
		if hitstun_timer > 0:
			pass 
		elif horizontal_speed > 0.2:
			if anim.current_animation != "Walk":
				anim.play("Walk") 
			anim.speed_scale = clampf(horizontal_speed / speed, 0.8, 1.4)
		else:
			if anim.current_animation != "Idle":
				anim.play("Idle")
			anim.speed_scale = 1.0
