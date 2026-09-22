extends Leaf
class_name LeafThrowAxe

@export var min_throw_range: float = 1.8
@export var max_throw_range: float = 15.0

func step() -> Result:
	var npc : AxeEnemy = owner
	var target = Globals.player
	if not target: return Result.FAILURE

	if npc.is_attacking:
		return Result.RUNNING

	var dist = npc.global_position.distance_to(target.global_position)
	
	if dist >= min_throw_range and dist <= max_throw_range:
		npc.velocity.x = 0
		npc.velocity.z = 0
		
		# Solución del error: Llamamos a la función sin el "if"
		if npc.has_method("start_throw_attack"):
			npc.start_throw_attack()
			return Result.RUNNING
				
	return Result.FAILURE
