extends Node3D
@export var keys : Array [Key]

func _ready() -> void:
	keys.shuffle()
	var real_key = keys[0]
	for key in keys:
		if key != real_key:
			key.queue_free()
