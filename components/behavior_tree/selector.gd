@icon("res://assets/icons/selector.svg")
extends BehaviorNode
class_name CompositorSelector

func step() -> Result:
	for child in get_children():
		if child is BehaviorNode:
			var child_result : Result = child.step()
			if child_result != Result.FAILURE:
				return child_result
	return Result.FAILURE
	
