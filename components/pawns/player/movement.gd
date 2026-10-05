extends Node
class_name MovementManager

@onready var player : Player = get_parent()
@onready var spring : SpringArm3D = $"../SpringArm3D"
@onready var weapon_manager = $"../WeaponManager"
@onready var mesh : Node3D = $"../PlayerMesh"
@onready var collision_shape : CollisionShape3D = $"../CollisionShape3D"

@export var jump_impulse : float = 6
@export var walk_speed : float = 2.5
@export var run_speed : float = 4
@export var max_step_height: float = 0.5 # Altura máxima del escalón que puede subir
@export_range(1,30) var slipperiness : float = 30

@export var crouch_speed : float = 4.0
var is_crouching : bool = false
var was_crouching : bool = false 

@export_group("Dash")
@export var dash_speed : float = 25.0
@export var dash_duration : float = 0.2
@export var dash_cooldown : float = 0.6

var _dash_cooldown_timer : float = 0.0
var _dash_direction : Vector3

@export_group("Knockback")
@export var knockback_force : float = 9.0
@export var knockback_duration : float = 0.25

var _knockback_timer : float = 0.0
var _knockback_dir : Vector3
var _current_knockback_force : float = 0.0

#running
var is_running = false
var is_aiming = false
var trapped = false 

#move smoothing
var expected_velocity : Vector3

func _physics_process(delta):
	
	if _dash_cooldown_timer > 0:
		_dash_cooldown_timer -= delta
	_process_dash_input()
	_process_cosmetic(delta)
	_process_player_jump()
	#_process_player_crouch(delta)
	_process_player_run(delta)
	_process_player_velocity(delta)
	_snap_up_stairs_check(delta)
	player.move_and_slide()
	

func _process_player_jump():
	if trapped or weapon_manager.is_attacking or is_dashing:
		return
		
	if Input.is_action_just_pressed("jump") and player.is_on_floor():
		player.velocity.y = jump_impulse
		player.anim.play("jump")

func _process_player_run(_delta : float):
	if not Globals.can_run:
		is_running = false
		return
		
	if Input.is_action_pressed("run"): is_running = true
	else: is_running = false
	if is_aiming:
		is_running = false
		return

func _process_player_velocity(delta : float):
	if _knockback_timer > 0:
		_knockback_timer -= delta
		expected_velocity = _knockback_dir * _current_knockback_force
		expected_velocity.y = player.velocity.y
		player.velocity = player.velocity.move_toward(expected_velocity, delta * slipperiness * 10)
		return
	if trapped:
		expected_velocity = Vector3.ZERO
		expected_velocity.y = player.velocity.y 
		player.velocity = player.velocity.move_toward(expected_velocity, delta * slipperiness * 10)
		return
	if is_dashing:
		expected_velocity = _dash_direction * dash_speed
		expected_velocity.y = player.velocity.y
		player.velocity = player.velocity.move_toward(expected_velocity, delta * slipperiness * player.velocity.distance_to(expected_velocity))
		return
	if weapon_manager.is_attacking:
		player.velocity = Vector3(0, player.velocity.y, 0)
		return
	var input_direction : Vector2 = Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var direction := Vector3(input_direction.x, 0, input_direction.y).rotated(Vector3(0, 1, 0), spring.rotation.y)
	expected_velocity = Vector3(direction.x * get_speed(), player.velocity.y, direction.z * get_speed())
	player.velocity = player.velocity.move_toward(expected_velocity, delta * slipperiness * player.velocity.distance_to(expected_velocity))

func _process_cosmetic(delta : float):
	# ELIMINAMOS el "if weapon_manager.is_attacking: return" que bloqueaba el giro
	
	# 1. Ahora el personaje siempre podrá girar siguiendo la cámara (Eje Y)
	mesh.global_rotation.y = lerp_angle(mesh.global_rotation.y, spring.global_rotation.y + PI, 9.0 * delta)
	
	# 2. Bloqueamos SOLO la actualización de animaciones base si está atacando o en el aire
	if weapon_manager.is_attacking or not player.is_on_floor():
		was_crouching = is_crouching
		return
		
	var anim : AnimationPlayer = player.anim
	var cur_anim = anim.current_animation
	var is_moving = Vector2(player.velocity.x, player.velocity.z).length() > 0.1 
	
	if is_crouching:
		if is_moving:
			anim.play("Crouch_walk", 0.2) 
		else:
			if not was_crouching and cur_anim != "Crouch":
				anim.play("Crouch", 0.1)
				anim.queue("Crouch_idle")
			elif cur_anim != "Crouch" and cur_anim != "Crouch_idle":
				anim.play("Crouch_idle", 0.2)
	else:
		if is_moving:
			anim.play("run" if is_running else "Walk")
		else:
			anim.play("Idle", 0.25) 
			
	was_crouching = is_crouching

##crouch
#func _process_player_crouch(delta: float):
	#if Input.is_action_pressed("crouch") and player.is_on_floor() and not is_dashing and not weapon_manager.is_attacking:
		#is_crouching = true
	#else:
		#is_crouching = false
	#var target_height = 1.0 if is_crouching else 2.0
	#collision_shape.shape.height = move_toward(collision_shape.shape.height, target_height, delta * 10.0)
	#
	#collision_shape.position.y = collision_shape.shape.height / 2.0

# dash
var is_dashing : bool

func _process_dash_input():
	if not Globals.can_dash:
		return
		
	if Input.is_action_just_pressed("dash") and not is_dashing and not weapon_manager.is_attacking and _dash_cooldown_timer <= 0:
		perform_dash()
		
func perform_dash():
	is_dashing = true
	player.invulnerable = true
	var input_direction : Vector2 = Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	if input_direction != Vector2.ZERO:
		_dash_direction = Vector3(input_direction.x, 0, input_direction.y).rotated(Vector3(0, 1, 0), spring.rotation.y).normalized()
	else:
		_dash_direction = -mesh.global_transform.basis.z.normalized()
	await get_tree().create_timer(dash_duration).timeout
	is_dashing = false
	player.invulnerable = false
	_dash_cooldown_timer = dash_cooldown

func get_speed():
	if is_crouching:
		return crouch_speed
	if is_running:
		return run_speed
	return walk_speed

func apply_knockback(attacker_pos: Vector3, mult: float = 1.0):
	_knockback_timer = knockback_duration
	_knockback_dir = player.global_position.direction_to(attacker_pos) * -1
	_knockback_dir.y = 0 
	_knockback_dir = _knockback_dir.normalized()
	_current_knockback_force = knockback_force * mult
	


func _snap_up_stairs_check(delta: float) -> void:
	if is_dashing or trapped:
		return
		
	var move_dir = Vector3(player.velocity.x, 0, player.velocity.z)
	if move_dir.length_squared() < 0.1:
		return
		
	# 1. Distancia de avance a probar (30 cm para pasar el borde del escalón)
	var forward_step = move_dir.normalized() * 0.3
	
	# 2. Si no choca a ras del suelo, no hay escalón en frente
	if not player.test_move(player.global_transform, forward_step):
		return
		
	# 3. Probamos si a la altura del escalón hay espacio libre
	var elevated_trans = player.global_transform.translated(Vector3(0, max_step_height, 0))
	if player.test_move(elevated_trans, forward_step):
		# Si arriba también choca, es una pared alta, no un escalón
		return
		
	# 4. Buscamos el piso del escalón hacia abajo desde la posición elevada
	var down_check = elevated_trans.translated(forward_step)
	var collision = KinematicCollision3D.new()
	
	if player.test_move(down_check, Vector3(0, -max_step_height * 1.2, 0), collision):
		# Calculamos cuánto bajó hasta tocar la superficie del peldaño
		var travel_y = collision.get_travel().y # Viene en negativo
		var step_lift = (max_step_height * 1.2) + travel_y
		
		# Teletransportamos al jugador en Y y un pequeño empujón en XZ para montarlo
		player.global_position += Vector3(0, step_lift + 0.03, 0) + (forward_step * 0.5)
