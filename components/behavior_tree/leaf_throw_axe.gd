extends Leaf
class_name LeafThrowAxe

@export var min_throw_range: float = 4.0
@export var max_throw_range: float = 15.0 

func step() -> Result:
	var npc: AxeEnemy = owner
	var target = Globals.player
	if not target: return Result.FAILURE

	if npc.is_attacking:
		return Result.RUNNING

	if npc._throw_timer > 0:
		return Result.FAILURE
		
	var dist = npc.global_position.distance_to(target.global_position)
	if dist >= min_throw_range and dist <= max_throw_range:
		npc.start_throw_attack()
		return Result.RUNNING

	return Result.FAILURE
