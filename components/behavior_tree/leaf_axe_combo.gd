extends Leaf
class_name LeafAxeCombo

@export var attack_range: float = 1.5
@export var damage: float = 25.0
@export var knockback_multiplier: float = 0.4 

func step() -> Result:
	var npc : Enemy = owner
	var target = Globals.player
	if not target: return Result.FAILURE

	# Si ya está reproduciendo la animación, mantenlo bloqueado aquí
	if npc.is_attacking:
		return Result.RUNNING

	var dist = npc.global_position.distance_to(target.global_position)
	if dist <= attack_range:
		if npc.has_method("execute_melee_combo"):
			npc.execute_melee_combo(damage, knockback_multiplier)
			return Result.RUNNING

	return Result.FAILURE
