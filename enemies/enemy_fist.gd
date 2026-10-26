extends Enemy
class_name FistEnemy

# ─── Hitboxes ─────────────────────────────────────────────────────────────────
@onready var right_fist: Area3D = %RightFistHitbox
@onready var left_fist: Area3D = %LeftFistHitbox
var _has_hit_player: bool = false

func _ready() -> void:
	max_health = 75.0
	health = 75.0
	speed = 3.2
	super._ready()
	if life_bar:
		life_bar.max_value = max_health
		life_bar.value = health
	_update_hp_label()

	right_fist.monitoring = false
	left_fist.monitoring = false
	right_fist.body_entered.connect(_on_fist_hit)
	left_fist.body_entered.connect(_on_fist_hit)


# ─── Hitbox Control ───────────────────────────────────────────────────────────
func open_right_fist() -> void:
	_has_hit_player = false
	right_fist.set_deferred("monitoring", true)


func open_left_fist() -> void:
	_has_hit_player = false
	left_fist.set_deferred("monitoring", true)


func close_fists() -> void:
	right_fist.set_deferred("monitoring", false)
	left_fist.set_deferred("monitoring", false)


func _on_fist_hit(body: Node3D) -> void:
	if _has_hit_player:
		return
	if body.is_in_group("player") and body.has_method("take_damage"):
		body.take_damage(current_damage, global_position, current_knockback)
		_has_hit_player = true


# ─── Movement ─────────────────────────────────────────────────────────────────
func perform_lunge(lunge_speed: float) -> void:
	is_lunging = true
	if player:
		var look_target := Vector3(player.global_position.x, global_position.y, player.global_position.z)
		look_at(look_target)
		rotation_degrees.y += 180
		var forward_dir := global_position.direction_to(player.global_position)
		velocity.x = forward_dir.x * lunge_speed
		velocity.z = forward_dir.z * lunge_speed
	get_tree().create_timer(0.2).timeout.connect(func(): is_lunging = false)


# ─── Combat ───────────────────────────────────────────────────────────────────
func execute_melee_combo(dmg: float, knockback: float) -> bool:
	if is_attacking or not anim:
		return false

	is_attacking = true
	current_damage = dmg
	current_knockback = knockback

	var combo := ["attack_1", "attack_2", "attack_3"]

	for i in range(combo.size()):
		if not is_attacking:
			break

		if player:
			var look_target := Vector3(player.global_position.x, global_position.y, player.global_position.z)
			look_at(look_target)
			rotation_degrees.y += 180

		if anim.has_animation(combo[i]):
			anim.play(combo[i])
			await anim.animation_finished
		else:
			push_error("FistEnemy: missing animation -> ", combo[i])
			break

		if i == combo.size() - 1:
			await get_tree().create_timer(0.8).timeout

	is_attacking = false
	return true


# ─── Animation ────────────────────────────────────────────────────────────────
func animation_process(_delta: float) -> void:
	if not anim or is_attacking:
		return

	var h_speed := Vector2(velocity.x, velocity.z).length()
	if hitstun_timer > 0:
		anim.play("Idle_E1")
	elif h_speed > 0.2:
		anim.play("walk_E1")
	else:
		anim.play("Idle_E1")
