extends Enemy
class_name AxeEnemy

@export var throw_cooldown: float = 3.0 # Ciclo de reposición exacto del GDD
@export var thrown_axe_damage: float = 25.0 # Daño exacto del GDD

var _throw_timer: float = 0.0
const axe_scene = preload("res://interactuables/weapons/throwable_axe.tscn")

func _ready():
	super._ready()
	health = 75.0 # Vida base según el GDD
	if life_bar:
		life_bar.max_value = health
		life_bar.value = health

func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	if _throw_timer > 0:
		_throw_timer -= delta

# --- ATAQUE A DISTANCIA ---
func start_throw_attack():
	if _throw_timer > 0 or is_attacking or not anim: 
		return false
		
	is_attacking = true
	velocity.x = 0
	velocity.z = 0
	
	# Apuntar al jugador antes de lanzar
	if player:
		var look_target = Vector3(player.global_position.x, global_position.y, player.global_position.z)
		look_at(look_target)
		rotation_degrees.y += 180
	
	# Asegúrate de que este nombre sea exacto en tu AnimationPlayer
	if anim.has_animation("Throw_E2"):
		anim.play("Throw_E2")
		await anim.animation_finished
	else:
		push_error("PELIGRO: Falta la animación throw_axe")
		
	is_attacking = false
	_throw_timer = throw_cooldown
	return true

# La animación llama a esto en el frame exacto donde suelta el arma
func spawn_projectile():
	var axe: RigidBody3D = axe_scene.instantiate()
	# Asigna las estadísticas antes de agregarlo al árbol
	if axe.get("damage") != null:
		axe.damage = thrown_axe_damage
	
	# El offset determina de dónde sale el hacha (ajústalo para que salga de su mano)
	var offset = Vector3(0.7, 1.5, 0)
	get_parent().add_child(axe)
	
	axe.global_position = global_position + offset.rotated(Vector3(0, 1, 0), rotation.y)
	axe.rotation.y = rotation.y
	
	if player:
		# Apunta un poco por encima de los pies del jugador para apuntar al pecho
		var target_pos = player.global_position + Vector3(0, 1.2, 0)
		var dir = axe.global_position.direction_to(target_pos)
		
		# Fuerza de lanzamiento
		axe.call_deferred("apply_central_impulse", dir * 16)
		# Hace que el hacha gire en el aire
		axe.call_deferred("apply_torque", Vector3(-20, 0, 0).rotated(Vector3(0, 1, 0), rotation.y))

func animation_process(delta):
	if anim and not is_attacking:
		var horizontal_speed = Vector2(velocity.x, velocity.z).length()
		
		if hitstun_timer > 0:
			pass 
		elif horizontal_speed > 0.2:
			anim.play("Walk_E2") 
		else:
			anim.play("Idle_E2")
