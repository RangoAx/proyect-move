extends Node
class_name CameraManager

var expected_rotation : Vector3
var expected_length : float = 2.0
var expected_offset : Vector2 = Vector2(0, 0)
@export var default_length : float = 2.0
@export var default_offset : Vector2 = Vector2(0.6, 0.15)
@export_range(1, 30) var slipperiness : float = 16.0
@onready var spring : SpringArm3D = $"../SpringArm3D"
@onready var camera : Camera3D = $"../SpringArm3D/Camera3D"

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	expected_length = default_length
	expected_offset = default_offset
	
	if spring:
		var player_body = get_parent()
		if player_body is CollisionObject3D:
			spring.add_excluded_object(player_body.get_rid())
		
		# Esfera de colisión para el SpringArm3D
		var sphere := SphereShape3D.new()
		sphere.radius = 0.2
		spring.shape = sphere
		spring.margin = 0.15
		spring.spring_length = default_length
		# Colisionar con el mundo físico (Layer 1) y con la canopia de árboles (Layer 8 / 128)
		spring.collision_mask = 1 | 128
	
	if camera:
		camera.h_offset = default_offset.x
		camera.v_offset = default_offset.y

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		expected_rotation.x -= event.screen_relative.y * Settings.mouse_sens * 0.001
		expected_rotation.x = clampf(expected_rotation.x, -PI/2, PI/2)
		expected_rotation.y += -event.screen_relative.x * Settings.mouse_sens * 0.001

func _physics_process(delta: float) -> void:
	if not spring or not camera:
		return
	
	var weight = clampf(delta * slipperiness, 0.0, 1.0)
	
	# Rotación suave de la cámara
	spring.rotation.x = lerp_angle(spring.rotation.x, expected_rotation.x, weight)
	spring.rotation.y = lerp_angle(spring.rotation.y, expected_rotation.y, weight)
	
	# Zoom y distancia base del SpringArm3D (permite apuntar con armas como el hacha)
	spring.spring_length = lerpf(spring.spring_length, expected_length, weight)
	
	# Detección de colisión del SpringArm3D:
	# Cuando la cámara choca con un árbol, muro u obstáculo, el SpringArm reduce automáticamente su distancia real.
	# Centramos suavemente la cámara horizontalmente y la elevamos ligeramente cuando se acerca al jugador,
	# evitando que se pegue o se meta en las hojas/troncos, manteniendo estabilidad sin vibraciones.
	var current_max : float = maxf(spring.spring_length, 0.001)
	var hit_dist : float = spring.get_hit_length()
	var col_ratio : float = clampf(hit_dist / current_max, 0.0, 1.0)
	
	var target_h : float = expected_offset.x * col_ratio
	var target_v : float = expected_offset.y + (1.0 - col_ratio) * 0.2
	
	camera.h_offset = lerpf(camera.h_offset, target_h, weight)
	camera.v_offset = lerpf(camera.v_offset, target_v, weight)
