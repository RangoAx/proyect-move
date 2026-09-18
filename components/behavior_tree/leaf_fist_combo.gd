extends Leaf
class_name LeafFistCombo

@export var attack_range: float = 1.8 
@export var damage: float = 15.0 
@export var knockback_multiplier: float = 0.08 
@export var combo_cooldown: float = 1.5

var _timer: float = 0.0

func step() -> Result:
	var npc : FistEnemy = owner
	var target = Globals.player
	if not target: return Result.FAILURE

	# El timer debe bajar independientemente de si ataca o no
	if _timer > 0.0:
		_timer -= get_physics_process_delta_time()

	if npc.is_attacking:
		return Result.RUNNING

	# Si está en cooldown, no ataca
	if _timer > 0.0:
		return Result.FAILURE

	var dist = npc.global_position.distance_to(target.global_position)
	if dist <= attack_range:
		npc.velocity.x = 0
		npc.velocity.z = 0
		
		if npc.has_method("execute_melee_combo"):
			npc.execute_melee_combo(damage, knockback_multiplier)
			_timer = combo_cooldown 
			return Result.RUNNING

	return Result.FAILURE
