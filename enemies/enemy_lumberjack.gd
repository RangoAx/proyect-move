extends Enemy

func _ready():
	health = 500.0
	super._ready() 

func animation_process(delta):
	if anim and not is_attacking:
		var horizontal_speed = Vector2(velocity.x, velocity.z).length()
		
		if hitstun_timer > 0:
			pass 
		elif horizontal_speed > 0.2:
			anim.play("walk") 
		else:
			anim.play("idle")

func execute_melee_combo(dmg: float, knockback: float):
	if is_attacking or not anim: 
		return false
		
	is_attacking = true
	current_damage = dmg
	current_knockback = knockback
	
	var combo = ["attack"]
	
	for i in range(combo.size()):
		var attack_anim = combo[i]
		
		if not is_attacking: 
			break 
			
		# Solo orienta al enemigo al inicio, el movimiento real lo dicta la animación
		if player:
			var look_target = Vector3(player.global_position.x, global_position.y, player.global_position.z)
			look_at(look_target)
			rotation_degrees.y += 180
			
		if anim.has_animation(attack_anim):
			anim.play(attack_anim)
			await anim.animation_finished
		else:
			push_error("PELIGRO: Falta la animación -> ", attack_anim)
			break
			
		if i == combo.size() - 1:
			await get_tree().create_timer(0.8).timeout
			
	is_attacking = false
	return true
