extends Pawn
class_name Player

@export var anim : AnimationPlayer

@onready var movement = $Movement
@onready var camera = $Camera
@onready var weapon_manager = $WeaponManager
@onready var life_bar = $CanvasLayer/MarginContainer/ProgressBar 

# Referencias a la pantalla de muerte ya existente en tu escena
@onready var death_screen: Control = $HUD/DeathScreen
@onready var btn_retry: Button = $HUD/DeathScreen/BtnRetry

@export var axe_amount : int = 1

var _heal_delay_timer : float = 0.0
var _heal_tick_timer : float = 0.0
var is_dead: bool = false

func _ready():
	Globals.player = self
	life_bar.value = health
	
	print("REFERENCIA AL BOTON: ", btn_retry) # <-- COMPROBACIÓN
	# Ocultar pantalla de muerte al iniciar y conectar botón
	if death_screen:
		death_screen.visible = false
	if btn_retry:
		btn_retry.pressed.connect(_on_retry_pressed)

func _process(delta: float) -> void:
	if is_dead:
		return
		
	life_bar.value = health
	life_bar.max_value = max_health
	if health < max_health and health > 0:
		_heal_delay_timer += delta

		if _heal_delay_timer >= 8.0:
			_heal_tick_timer -= delta
			if _heal_tick_timer <= 0.0:
				health += 1
				if health > max_health:
					health = max_health
				_heal_tick_timer = 0.2 
	else:
		_heal_delay_timer = 0.0
		_heal_tick_timer = 3.0 

func take_damage(damage: float, attacker_pos: Vector3 = Vector3.ZERO, knockback_mult: float = 1.0):
	if is_dead:
		return
		
	super.take_damage(damage, attacker_pos, knockback_mult)
	
	_heal_delay_timer = 0.0
	_heal_tick_timer = 3.0
	
	if health > 0 and attacker_pos != Vector3.ZERO and knockback_mult > 0.0:
		movement.apply_knockback(attacker_pos, knockback_mult)

# --- REEMPLAZO DEL DIE DE PAWN ---
func die():
	if is_dead:
		return
		
	is_dead = true
	invulnerable = true # Evita que Pawn vuelva a llamar a die() cada frame
	
	# Frenar por completo movimiento y físicas
	velocity = Vector3.ZERO
	if movement:
		movement.trapped = true
		
	# Mostrar pantalla de muerte con fondo rojo según el GDD
	if death_screen:
		death_screen.visible = true
		
	# Liberar el ratón para poder pulsar el botón de reintento
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func _on_retry_pressed():
	# Reinicia la escena completa limpiando enemigos, objetos y vida
	get_tree().reload_current_scene()
