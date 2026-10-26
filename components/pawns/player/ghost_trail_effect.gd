extends Node3D
class_name GhostTrailEffect

@export var duration: float = 0.3
@export var ghost_color: Color = Color(0.2, 0.7, 1.0, 0.6) # Vibrant cyan/blue trail

var _timer: float = 0.0
var _mat: StandardMaterial3D

func _ready() -> void:
	_mat = StandardMaterial3D.new()
	_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	_mat.albedo_color = ghost_color
	_mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	
	# Apply material override to all child mesh instances (recursive=true, owned=false)
	for child in find_children("*", "MeshInstance3D", true, false):
		var mi := child as MeshInstance3D
		mi.material_override = _mat

func _process(delta: float) -> void:
	_timer += delta
	var progress := _timer / maxf(0.01, duration)
	if progress >= 1.0:
		queue_free()
		return
	
	var fade: float = 1.0 - progress
	_mat.albedo_color = Color(ghost_color.r, ghost_color.g, ghost_color.b, ghost_color.a * (fade * fade))

