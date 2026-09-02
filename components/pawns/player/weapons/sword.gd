extends Weapon
class_name SwordWeapon

@export var sword_area : Area3D
var enemies_hit = []

var base_damage : float = 20.0
var is_estocada : bool = false
var estocada_hit : bool = false

func get_damage() -> float:
	if Globals.knife_level >= 3:
		return 25.0 # Nivel 3: Aumento de daño a 25
	return base_damage # Nivel 1: Daño base de 20

func _ready():
	sword_area.monitoring = false
	if not sword_area.body_entered.is_connected(_on_body_entered):
		sword_area.body_entered.connect(_on_body_entered)

func hitbox_open():
	enemies_hit.clear()
	sword_area.set_deferred("monitoring", true)

func hitbox_close():
	sword_area.set_deferred("monitoring", false)

# Ataque básico (Combo de 3 golpes)[cite: 1]
func attack():
	is_estocada = false
	if await play_interruptible_animation("Ataque1", 0.2):
		pass
	else:
		if await play_interruptible_animation("Ataque2", 0.2):
			pass
		else:
			await play_interruptible_animation("Ataque3", 0.2)
			
	end()

# Nivel 2: Estocada (se puede enlazar a aim_attack() en WeaponManager)[cite: 1]
func aim_attack():
	try_estocada()

func try_estocada():
	if Globals.knife_level < 2:
		return
	
	is_estocada = true
	estocada_hit = false
	
	# 0.8s de preparación (Carga)[cite: 1]
	# Opcional: anim.play("Estocada_Charge")
	await get_tree().create_timer(0.8).timeout
	
	# Ventana de impacto activa
	hitbox_open()
	# Opcional: anim.play("Estocada_Thrust")
	await get_tree().create_timer(0.2).timeout
	hitbox_close()
	
	# Factor de riesgo: si no conecta, entra en vulnerabilidad por 0.8s[cite: 1]
	if not estocada_hit:
		# Bloquea al jugador temporalmente deteniendo su movimiento
		if player.movement:
			player.movement.trapped = true
		
		await get_tree().create_timer(0.8).timeout
		
		if player.movement:
			player.movement.trapped = false
	
	is_estocada = false
	end()

func _on_body_entered(body : Node3D):
	if body is NPC:
		if body in enemies_hit:
			return
		enemies_hit.append(body)
		
		# Determina el daño según el tipo de ataque actual
		var damage_to_deal : float = 50.0 if is_estocada else get_damage()
		body.take_damage(damage_to_deal, player.global_position)
		
		if is_estocada:
			estocada_hit = true

func end():
	sword_area.set_deferred("monitoring", false)
