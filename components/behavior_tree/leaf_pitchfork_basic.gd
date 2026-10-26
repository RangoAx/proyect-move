extends Leaf
class_name LeafPitchforkBasic

@export var attack_range: float = 2.4
@export var damage: float = 25.0
@export var recovery_time: float = 0.8
@export var vulnerability_time: float = 0.8
@export var knockback_multiplier: float = 0.5

var _internal_state: String = "idle"
var _timer: float = 0.0

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

	if npc.state != "idle" and npc.state != "basic_attack":
		return Result.FAILURE

	var dist := npc.global_position.distance_to(target.global_position)

	match _internal_state:
		"idle":
			owner.is_attacking = false
			if dist > attack_range:
				return Result.FAILURE

			npc.state = "basic_attack"
			_internal_state = "anticipation"
			_timer = 0.35
			npc.velocity.x = 0
			npc.velocity.z = 0
			owner.is_attacking = true
			if owner.anim:
				owner.anim.play("attacks/cargando_ataque")

		"anticipation":
			owner.is_attacking = true
			npc.velocity.x = 0
			npc.velocity.z = 0
			var look_target := Vector3(target.global_position.x, npc.global_position.y, target.global_position.z)
			if npc.global_position.distance_to(look_target) > 0.1:
				npc.look_at(look_target)
				npc.rotation_degrees.y += 180
			_timer -= get_physics_process_delta_time()
			
			if _timer <= 0:
				_internal_state = "attack"
				_timer = 0.35
				if owner.anim:
					owner.anim.play("attacks/estocada_ataque")
				var hit_dist := npc.global_position.distance_to(target.global_position)
				if hit_dist <= attack_range * 1.3:
					if target.has_method("take_damage"):
						target.take_damage(damage, npc.global_position, knockback_multiplier)

		"attack":
			owner.is_attacking = true
			npc.velocity.x = 0
			npc.velocity.z = 0
			_timer -= get_physics_process_delta_time()
			
			if _timer <= 0:
				_internal_state = "recovery"
				_timer = recovery_time

		"recovery", "vulnerable":
			owner.is_attacking = false
			npc.velocity.x = 0
			npc.velocity.z = 0
			_timer -= get_physics_process_delta_time()
			
			if _timer <= 0:
				_internal_state = "idle"
				npc.state = "idle"
				return Result.SUCCESS

	return Result.RUNNING
