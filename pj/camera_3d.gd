extends Camera3D

@onready var _camera := %Camera3D as Camera3D
@onready var _camera_pivot := %CameraPivot as Node3D
@onready var _spring_arm := %SpringArm3D as SpringArm3D
@export var player : CharacterBody3D
@export var cam_transition_speed: float = 10.0
@export var camera_weight : float = 18
@export var normal_length: float = 4.5
@export var aim_length: float = 1.5
var direction 
var tilt_limit = deg_to_rad(75)
var expected_rotation : Vector3 = Vector3(0, 0, 0)
var expected_velocity : Vector3 = Vector3(0, 0, 0)


func _ready() -> void:
	pass

func _physics_process(delta: float) -> void:
	expected_velocity.x = direction.x * speed
	expected_velocity.z = direction.z * speed
	expected_velocity.y = velocity.y
	velocity = velocity.move_toward(expected_velocity, delta * velocity_weight * velocity.distance_to(expected_velocity))
	_camera_pivot.rotation = _camera_pivot.rotation.move_toward(expected_rotation,delta * camera_weight * _camera_pivot.rotation.distance_to(expected_rotation))
