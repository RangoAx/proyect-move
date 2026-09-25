extends Enemy
class_name FistEnemy

@onready var right_fist: Area3D = %RightFistHitbox
@onready var left_fist: Area3D = %LeftFistHitbox
var has_hit_player: bool = false

func _ready():
	speed = 3.2
	super._ready() 
	
	right_fist.monitoring = false
	left_fist.monitoring = false
	
	right_fist.body_entered.connect(_on_fist_hit)
	left_fist.body_entered.connect(_on_fist_hit)

# --- SISTEMA DE HITBOXES (MANOS INDEPENDIENTES) ---
func open_right_fist():
	has_hit_player = false
	right_fist.set_deferred("monitoring", true)

func open_left_fist():
	has_hit_player = false
	left_fist.set_deferred("monitoring", true)

func close_fists():
	right_fist.set_deferred("monitoring", false)
	left_fist.set_deferred("monitoring", false)

func _on_fist_hit(body: Node3D):
	if has_hit_player: return 
	
	if body.is_in_group("player") and body.has_method("take_damage"):
		body.take_damage(current_damage, global_position, current_knockback)
		has_hit_player = true

func perform_lunge(speed: float):
	is_lunging = true
	
	if player:
		# Corrige la puntería justo en el frame que da el paso
		var look_target = Vector3(player.global_position.x, global_position.y, player.global_position.z)
		look_at(look_target)
		rotation_degrees.y += 180
		
		var forward_dir = global_position.direction_to(player.global_position)
		velocity.x = forward_dir.x * speed
		velocity.z = forward_dir.z * speed
	get_tree().create_timer(0.2).timeout.connect(func(): is_lunging = false)
# --- LÓGICA DEL COMBO ---
func execute_melee_combo(dmg: float, knockback: float):
	if is_attacking or not anim: 
		return false
		
	is_attacking = true
	current_damage = dmg
	current_knockback = knockback
	
	var combo = ["attack_1", "attack_2", "attack_3"]
	
	for i in range(combo.size()):
		var attack_anim = combo[i]
		
		if not is_attacking: 
			break 
			
		# Solo orienta al enemigo al inicio, el movimiento real lo dicta la animación
		if player:
			var look_target = Vector3(player.global_position.x, global_position.y, player.global_position.z)
			look_at(look_target)
			rotation_degrees.y += 180
			
		if anim.has_animation(attack_anim):
			anim.play(attack_anim)
			await anim.animation_finished
		else:
			push_error("PELIGRO: Falta la animación -> ", attack_anim)
			break
			
		if i == combo.size() - 1:
			await get_tree().create_timer(0.8).timeout
			
	is_attacking = false
	return true

func animation_process(delta):
	# --- GESTOR DE ANIMACIONES DE MOVIMIENTO ---
	if anim and not is_attacking:
		# Mide qué tan rápido se mueve en el suelo (ignora la gravedad en Y)
		var horizontal_speed = Vector2(velocity.x, velocity.z).length()
		
		# Si está aturdido por un golpe, no camina
		if hitstun_timer > 0:
			pass # Aquí podrías poner anim.play("hurt") en el futuro
		elif horizontal_speed > 0.2:
			anim.play("walk_E1") # Asegúrate que se llame así en tu AnimationPlayer
		else:
			anim.play("Idle_E1")    # Asegúrate que se llame así en tu AnimationPlayer

func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	#print(left_fist.monitoring or right_fist.monitoring)
	#print(left_fist.get_overlapping_bodies())
	
