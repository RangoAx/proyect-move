@icon("res://assets/icons/sequence.svg")
extends BehaviorNode
class_name CompositorSequencer

func step() -> Result:
	for child in get_children():
		if child is BehaviorNode:
			var child_result : Result = child.step()
			if child_result != Result.SUCCESS:
				return child_result
	return Result.SUCCESS
	
