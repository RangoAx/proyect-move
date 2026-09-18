extends MeshInstance3D

@export_group("Trail Settings")
@export var trail_lifetime : float = 0.22 # Duración de la estela
@export var min_step : float = 0.03       # Suavizado independiente de FPS (3 cm)

# Coordenadas locales en Cuchillo loco (punta y base del corte)
@export var tip_offset : Vector3 = Vector3(-0.008, 0.017, 0.64)
@export var base_offset : Vector3 = Vector3(-0.008, 0.017, 0.50)

var is_emitting : bool = false
var _was_emitting : bool = false

var segments : Array[Dictionary] = []
var last_tip : Vector3 = Vector3.ZERO
var last_base : Vector3 = Vector3.ZERO
var has_recorded : bool = false

@onready var imm_mesh = ImmediateMesh.new()

func _ready():
	mesh = imm_mesh
	top_level = true
	global_transform = Transform3D.IDENTITY
	
	var mat = StandardMaterial3D.new()
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.blend_mode = BaseMaterial3D.BLEND_MODE_ADD
	mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	mat.vertex_color_use_as_albedo = true
	material_override = mat

func _process(delta):
	var knife = get_parent()
	if not knife:
		return

	# Si empieza un ataque nuevo, borra trazos anteriores de golpe
	if is_emitting and not _was_emitting:
		segments.clear()
		has_recorded = false
		
	_was_emitting = is_emitting

	# 1. Muestreo de la punta y base del filo
	if is_emitting:
		var current_tip = knife.to_global(tip_offset)
		var current_base = knife.to_global(base_offset)

		if not has_recorded:
			segments.push_front({"tip": current_tip, "base": current_base, "age": 0.0})
			last_tip = current_tip
			last_base = current_base
			has_recorded = true
		else:
			var dist = last_tip.distance_to(current_tip)
			if dist >= min_step:
				var steps = int(dist / min_step)
				for s in range(1, steps + 1):
					var t = float(s) / float(steps)
					segments.push_front({
						"tip": last_tip.lerp(current_tip, t),
						"base": last_base.lerp(current_base, t),
						"age": 0.0
					})
				last_tip = current_tip
				last_base = current_base
			else:
				if segments.size() > 0:
					segments[0]["tip"] = current_tip
					segments[0]["base"] = current_base

	# 2. Desvanecimiento por tiempo real
	var i = segments.size() - 1
	while i >= 0:
		segments[i]["age"] += delta
		if segments[i]["age"] >= trail_lifetime:
			segments.remove_at(i)
		i -= 1

	# 3. Dibujado de la cinta
	imm_mesh.clear_surfaces()
	if segments.size() < 2:
		return

	imm_mesh.surface_begin(Mesh.PRIMITIVE_TRIANGLE_STRIP)
	for j in range(segments.size()):
		var seg = segments[j]
		var age_ratio = clampf(seg["age"] / trail_lifetime, 0.0, 1.0)
		
		# Afila la punta hacia el final
		var center = seg["tip"].lerp(seg["base"], 0.5)
		var width_factor = 1.0 - age_ratio
		var v_tip = center.lerp(seg["tip"], width_factor)
		var v_base = center.lerp(seg["base"], width_factor)
		
		var alpha = lerp(0.85, 0.0, age_ratio)
		imm_mesh.surface_set_color(Color(3.5, 3.5, 3.5, alpha))
		
		imm_mesh.surface_add_vertex(v_tip)
		imm_mesh.surface_add_vertex(v_base)
		
	imm_mesh.surface_end()
