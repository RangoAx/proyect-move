extends Enemy

func _ready() -> void:
	health = 500.0
	super._ready()


# ─── Combat ───────────────────────────────────────────────────────────────────
func execute_melee_combo(dmg: float, knockback: float) -> bool:
	if is_attacking or not anim:
		return false

	is_attacking = true
	current_damage = dmg
	current_knockback = knockback

	if player:
		var look_target := Vector3(player.global_position.x, global_position.y, player.global_position.z)
		look_at(look_target)
		rotation_degrees.y += 180

	if anim.has_animation("attack"):
		anim.play("attack")
		await anim.animation_finished
	else:
		push_error("LumberjackEnemy: missing animation -> attack")

	await get_tree().create_timer(0.8).timeout
	is_attacking = false
	return true


# ─── Animation ────────────────────────────────────────────────────────────────
func animation_process(_delta: float) -> void:
	if not anim or is_attacking:
		return

	var h_speed := Vector2(velocity.x, velocity.z).length()
	if hitstun_timer > 0:
		pass
	elif h_speed > 0.2:
		anim.play("walk")
	else:
		anim.play("idle")
