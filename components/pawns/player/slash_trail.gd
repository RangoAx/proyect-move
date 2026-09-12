extends MeshInstance3D

# Ajusta el tiempo que la estela permanece en el aire (en segundos)
@export var trail_lifetime : float = 0.35 
@export var max_points : int = 35

var is_emitting : bool = false
var _was_emitting : bool = false
var points : Array[Vector3] = []
var point_ages : Array[float] = []

@onready var imm_mesh = ImmediateMesh.new()

func _ready():
	mesh = imm_mesh
	
	var mat = StandardMaterial3D.new()
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.blend_mode = BaseMaterial3D.BLEND_MODE_ADD
	mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	mat.vertex_color_use_as_albedo = true
	material_override = mat

func _process(delta):
	# Limpia trazos viejos si inicias un golpe nuevo
	if is_emitting and not _was_emitting:
		points.clear()
		point_ages.clear()
		
	_was_emitting = is_emitting

	# Registra nuevos puntos mientras el ataque esté activo
	if is_emitting:
		points.push_front(global_transform.origin)
		point_ages.push_front(0.0)
		if points.size() > max_points:
			points.pop_back()
			point_ages.pop_back()

	# Envejece cada punto individualmente y elimina los que expiren
	var i = point_ages.size() - 1
	while i >= 0:
		point_ages[i] += delta
		if point_ages[i] >= trail_lifetime:
			points.remove_at(i)
			point_ages.remove_at(i)
		i -= 1

	imm_mesh.clear_surfaces()
	if points.size() < 2:
		return

	# Dibuja la cinta suavizada por tiempo
	imm_mesh.surface_begin(Mesh.PRIMITIVE_TRIANGLE_STRIP)
	for j in range(points.size()):
		var global_p = points[j]
		var age_ratio = point_ages[j] / trail_lifetime # 0.0 (nuevo) a 1.0 (a punto de desaparecer)
		
		# Se afila y se desvanece suavemente conforme pasa el tiempo
		var size = lerp(0.08, 0.0, age_ratio)
		var alpha = lerp(0.8, 0.0, age_ratio)
		
		imm_mesh.surface_set_color(Color(3.0, 3.0, 3.0, alpha))
		
		var top_vertex = to_local(global_p + Vector3(0, size, 0))
		var bottom_vertex = to_local(global_p - Vector3(0, size, 0))
		
		imm_mesh.surface_add_vertex(top_vertex)
		imm_mesh.surface_add_vertex(bottom_vertex)
		
	imm_mesh.surface_end()
