extends CharacterBody3D

@onready var _camera := %Camera3D as Camera3D
@onready var _camera_pivot := %CameraPivot as Node3D
@export var mesh : MeshInstance3D
@export_range(0.1, 3.0) var mouse_sensitivity : float = 1.8
@export var camera_weight : float = 18
var tilt_limit = deg_to_rad(75)
var expected_rotation : Vector3 = Vector3(0, 0, 0)
var expected_velocity : Vector3 = Vector3(0, 0, 0)

@export var speed = 7.0
@export var velocity_weight = 10
@export var jump_velocity = 15
@export var gravity: float = 1


func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _physics_process(delta: float) -> void:
	#soft camera movement and movement
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_velocity
	var input_direction := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var direction := Vector3(input_direction.x,0,input_direction.y).rotated(Vector3(0,1,0),_camera_pivot.rotation.y)
	_camera_pivot.rotation = _camera_pivot.rotation.move_toward(expected_rotation,delta * camera_weight * _camera_pivot.rotation.distance_to(expected_rotation))
	if not is_on_floor():
		velocity.y -= gravity
	expected_velocity.x = direction.x * speed
	expected_velocity.z = direction.z * speed
	expected_velocity.y = velocity.y
	velocity = velocity.move_toward(expected_velocity, delta * velocity_weight * velocity.distance_to(expected_velocity))
	#mesh orientation
	var old_rotation = mesh.rotation
	mesh.look_at(position + direction)
	var new_rotation = mesh.rotation
	mesh.rotation = old_rotation
	mesh.rotation.y = lerp_angle(mesh.rotation.y, new_rotation.y, delta * 10)
	move_and_slide()

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		expected_rotation.x -= event.screen_relative.y * mouse_sensitivity * 0.001
		expected_rotation.x = clampf(expected_rotation.x, -tilt_limit, tilt_limit)
		expected_rotation.y += -event.screen_relative.x * mouse_sensitivity * 0.001
