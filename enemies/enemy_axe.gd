extends Enemy
class_name AxeEnemy

# ─── Config ───────────────────────────────────────────────────────────────────
@export var throw_cooldown: float = 3.0
@export var thrown_axe_damage: float = 25.0
@export var throw_speed: float = 16.0

@export_group("Melee (close-range fallback)")
@export var melee_hitbox_duration: float = 0.3
@export var melee_recovery: float = 0.4

# ─── Nodes ────────────────────────────────────────────────────────────────────
@onready var melee_hitbox: Area3D = %AxeMeleeHitbox

# ─── State ────────────────────────────────────────────────────────────────────
var _throw_timer: float = 0.0
var _has_hit_player: bool = false

const axe_scene = preload("res://interactuables/weapons/throwable_axe.tscn")
const MELEE_ANIM_RES = preload("res://pj/animations/Ataque1.res")

func _ready() -> void:
	super._ready()
	health = 75.0
	if life_bar:
		life_bar.max_value = health
		life_bar.value = health
	_update_hp_label()
	melee_hitbox.monitoring = false
	melee_hitbox.body_entered.connect(_on_melee_hit)


func _setup_anim() -> void:
	super._setup_anim()
	_setup_melee_animation()


func _setup_melee_animation() -> void:
	if not anim:
		return
	var lib: AnimationLibrary
	if anim.has_animation_library(""):
		lib = anim.get_animation_library("")
	else:
		lib = AnimationLibrary.new()
		anim.add_animation_library("", lib)

	if not lib.has_animation("Ataque1"):
		var clean_anim: Animation = MELEE_ANIM_RES.duplicate()
		for t in range(clean_anim.get_track_count() - 1, -1, -1):
			var tpath := str(clean_anim.track_get_path(t))
			if "WeaponManager" in tpath:
				clean_anim.remove_track(t)
			elif clean_anim.track_get_type(t) == Animation.TYPE_POSITION_3D and "Hips" in tpath:
				clean_anim.remove_track(t)
		lib.add_animation("Ataque1", clean_anim)


func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	if _throw_timer > 0:
		_throw_timer -= delta


# ─── Ranged Attack ────────────────────────────────────────────────────────────
func start_throw_attack() -> bool:
	if _throw_timer > 0 or is_attacking or not anim:
		return false

	is_attacking = true
	velocity.x = 0
	velocity.z = 0

	_face_player()

	if anim.has_animation("Throw_E2"):
		anim.play("Throw_E2")
		await anim.animation_finished
	else:
		push_error("AxeEnemy: missing animation -> Throw_E2")

	is_attacking = false
	_throw_timer = throw_cooldown
	return true


# Called by an AnimationPlayer Call Method track at the release frame.
func spawn_projectile() -> void:
	if player:
		_face_player()

	var axe: RigidBody3D = axe_scene.instantiate()
	if axe.get("damage") != null:
		axe.damage = thrown_axe_damage
	if axe.get("thrower") != null:
		axe.thrower = self

	var offset := Vector3(-0.6, 1.3, 0)
	get_parent().add_child(axe)
	axe.global_position = global_position + offset.rotated(Vector3(0, 1, 0), rotation.y)
	axe.rotation.y = rotation.y

	if player:
		var target_pos := player.global_position + Vector3(0, 1.0, 0)
		var diff := target_pos - axe.global_position
		var horizontal_diff := Vector3(diff.x, 0.0, diff.z)
		var d := horizontal_diff.length()
		var h := diff.y

		var g: float = ProjectSettings.get_setting("physics/3d/default_gravity", 9.8)
		var speed: float = throw_speed

		var impulse: Vector3
		if d > 0.01:
			var horizontal_dir := horizontal_diff / d
			var v2 := speed * speed
			var v4 := v2 * v2
			var discriminant := v4 - g * (g * d * d + 2.0 * h * v2)

			var theta: float = 0.0
			if discriminant >= 0.0:
				var tan_theta := (v2 - sqrt(discriminant)) / (g * d)
				theta = atan(tan_theta)
			else:
				theta = deg_to_rad(45.0) if h >= 0 else deg_to_rad(-45.0)

			impulse = (horizontal_dir * (speed * cos(theta))) + (Vector3.UP * (speed * sin(theta)))
		else:
			impulse = Vector3.UP * speed

		axe.call_deferred("apply_central_impulse", impulse)
		axe.call_deferred("apply_torque", Vector3(-20, 0, 0).rotated(Vector3(0, 1, 0), rotation.y))


# ─── Melee Attack (close-range fallback) ──────────────────────────────────────
func execute_melee_combo(dmg: float, knockback: float) -> bool:
	if is_attacking or not anim:
		return false

	is_attacking = true
	current_damage = dmg
	current_knockback = knockback

	_face_player()

	if anim.has_animation("Ataque1"):
		anim.play("Ataque1")
		var duration := anim.current_animation_length
		if duration <= 0.0:
			duration = 0.35
		var swing_delay := minf(0.12, duration * 0.4)
		await get_tree().create_timer(swing_delay).timeout
		if not is_attacking:
			close_melee_hitbox()
			return false
		open_melee_hitbox()
		await get_tree().create_timer(maxf(0.01, duration - swing_delay)).timeout
	else:
		push_error("AxeEnemy: missing animation -> Ataque1")

	close_melee_hitbox()  # safety net in case animation didn't close it
	if is_attacking:
		await get_tree().create_timer(melee_recovery).timeout
	is_attacking = false
	return true


func open_melee_hitbox() -> void:
	_has_hit_player = false
	melee_hitbox.monitoring = true

	if player:
		var dist := global_position.distance_to(player.global_position)
		if dist <= 2.2:
			_on_melee_hit(player)

	get_tree().create_timer(melee_hitbox_duration).timeout.connect(close_melee_hitbox)


func close_melee_hitbox() -> void:
	melee_hitbox.set_deferred("monitoring", false)


func _on_melee_hit(body: Node3D) -> void:
	if _has_hit_player:
		return
	if body.is_in_group("player") and body.has_method("take_damage"):
		body.take_damage(current_damage, global_position, current_knockback)
		_has_hit_player = true


# ─── Animation ────────────────────────────────────────────────────────────────
func animation_process(_delta: float) -> void:
	if not anim or is_attacking:
		return

	var h_speed := Vector2(velocity.x, velocity.z).length()
	if hitstun_timer > 0:
		pass
	elif h_speed > 0.2:
		anim.play("Walk_E2")
	else:
		anim.play("Idle_E2")


# ─── Helpers ──────────────────────────────────────────────────────────────────
func _face_player() -> void:
	if not player:
		return
	var look_target := Vector3(player.global_position.x, global_position.y, player.global_position.z)
	look_at(look_target)
	rotation_degrees.y += 180
