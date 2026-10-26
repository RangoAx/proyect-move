extends Leaf
class_name LeafPitchforkCharge

@export var min_charge_range: float = 3.5
@export var max_charge_range: float = 8.5
@export var charge_speed: float = 12.0
@export var damage: float = 55.0
@export var windup_time: float = 0.9
@export var vulnerability_time: float = 1.5
@export var knockback_multiplier: float = 1.5
@export var charge_cooldown: float = 4.0

var _internal_state: String = "idle"
var _timer: float = 0.0
var _cooldown_timer: float = 0.0
var _charge_dir: Vector3 = Vector3.ZERO

func _ready() -> void:
	if owner is NPC:
		owner.took_damage.connect(_on_took_damage)

func _on_took_damage() -> void:
	_internal_state = "idle"
	if owner:
		if "state" in owner:
			owner.state = "idle"
		if "is_attacking" in owner:
			owner.is_attacking = false
		if "is_lunging" in owner:
			owner.is_lunging = false
		if "override_look" in owner:
			owner.override_look = false

func step() -> Result:
	var npc : Enemy = owner
	if not npc:
		return Result.FAILURE

	var target : Node3D = npc.player
	if not target and is_inside_tree():
		target = get_tree().get_first_node_in_group("player") as Node3D
	if not target:
		return Result.FAILURE

	if _cooldown_timer > 0.0 and _internal_state == "idle":
		_cooldown_timer -= get_physics_process_delta_time()

	if npc.state != "idle" and npc.state != "charge_attack":
		return Result.FAILURE

	var dist := npc.global_position.distance_to(target.global_position)

	match _internal_state:
		"idle":
			owner.is_attacking = false
			owner.is_lunging = false
			npc.override_look = false
			if _cooldown_timer > 0.0:
				return Result.FAILURE
			if dist < min_charge_range or dist > max_charge_range:
				return Result.FAILURE

			npc.state = "charge_attack"
			_internal_state = "windup"
			_timer = windup_time
			owner.is_attacking = true
			owner.is_lunging = false
			if owner.anim:
				owner.anim.play("attacks/cargando_ataque")

		"windup":
			owner.is_attacking = true
			owner.is_lunging = false
			var look_target := Vector3(target.global_position.x, npc.global_position.y, target.global_position.z)
			if npc.global_position.distance_to(look_target) > 0.1:
				npc.look_at(look_target)
				npc.rotation_degrees.y += 180

			# Slight backstep during initial windup
			if _timer > windup_time * 0.5:
				var back_dir := npc.global_position.direction_to(target.global_position) * -1.0
				back_dir.y = 0.0
				back_dir = back_dir.normalized() * 2.0
				npc.velocity.x = back_dir.x
				npc.velocity.z = back_dir.z
			else:
				npc.velocity.x = move_toward(npc.velocity.x, 0.0, get_physics_process_delta_time() * 20.0)
				npc.velocity.z = move_toward(npc.velocity.z, 0.0, get_physics_process_delta_time() * 20.0)

			_timer -= get_physics_process_delta_time()
			if _timer <= 0:
				_charge_dir = npc.global_position.direction_to(target.global_position)
				_charge_dir.y = 0.0
				_charge_dir = _charge_dir.normalized()
				_internal_state = "charging"
				_timer = 0.85
				owner.is_lunging = true
				npc.override_look = true
				if _charge_dir.length_squared() > 0.01:
					npc.look_at(npc.global_position + _charge_dir)
					npc.rotation_degrees.y += 180
				if owner.anim:
					owner.anim.play("attacks/cargando_ataque")

		"charging":
			owner.is_attacking = true
			owner.is_lunging = true
			npc.override_look = true
			npc.velocity.x = _charge_dir.x * charge_speed
			npc.velocity.z = _charge_dir.z * charge_speed
			_timer -= get_physics_process_delta_time()

			var hit_dist := npc.global_position.distance_to(target.global_position)
			if hit_dist <= 1.8:
				if target.has_method("take_damage"):
					target.take_damage(damage, npc.global_position, knockback_multiplier)
				_internal_state = "charge_attack"
				_timer = 0.35
				owner.is_lunging = false
				npc.velocity.x = 0.0
				npc.velocity.z = 0.0
				if owner.anim:
					owner.anim.play("attacks/estocada_ataque")
			elif _timer <= 0 or npc.is_on_wall():
				# Missed charge or bumped wall -> 1.5s stun vulnerability per GDD
				_internal_state = "vulnerable"
				_timer = vulnerability_time
				owner.is_lunging = false
				owner.is_attacking = false
				npc.velocity.x = 0.0
				npc.velocity.z = 0.0

		"charge_attack":
			owner.is_attacking = true
			owner.is_lunging = false
			npc.velocity.x = 0.0
			npc.velocity.z = 0.0
			_timer -= get_physics_process_delta_time()
			if _timer <= 0:
				_internal_state = "vulnerable"
				_timer = vulnerability_time
				owner.is_attacking = false

		"vulnerable":
			owner.is_attacking = false
			owner.is_lunging = false
			npc.override_look = false
			npc.velocity.x = move_toward(npc.velocity.x, 0.0, get_physics_process_delta_time() * 20.0)
			npc.velocity.z = move_toward(npc.velocity.z, 0.0, get_physics_process_delta_time() * 20.0)

			_timer -= get_physics_process_delta_time()
			if _timer <= 0:
				_internal_state = "idle"
				npc.state = "idle"
				_cooldown_timer = charge_cooldown
				return Result.SUCCESS

	return Result.RUNNING
