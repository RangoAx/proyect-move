extends Leaf
class_name LeafFollowTarget

@export var is_target_player : bool = false
@export var target : Node3D
@export var target_distance : float

func step() -> Result:
	var npc : Enemy = owner
	if not is_target_player:
		if not target:
			return Result.FAILURE
	else:
		target = Globals.player
		npc.nav.target_position = target.global_position
	if npc.global_position.distance_to(target.global_position) <= target_distance:
		return Result.SUCCESS
	var direction := npc.global_position.direction_to(npc.nav.get_next_path_position())
	npc.velocity = Vector3(direction.x * npc.speed, npc.velocity.y, direction.z * npc.speed)
	return Result.RUNNING
