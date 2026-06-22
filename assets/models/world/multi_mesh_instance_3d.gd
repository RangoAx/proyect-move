extends MultiMeshInstance3D

const TREE_COL = preload("res://assets/models/world/tree_col.tscn")

func _ready() -> void:
	for instance in multimesh.instance_count:
		var instance_transform: Transform3D = multimesh.get_instance_transform(instance)

		var col = TREE_COL.instantiate()
		add_child(col)
		
		col.global_transform = global_transform * instance_transform
