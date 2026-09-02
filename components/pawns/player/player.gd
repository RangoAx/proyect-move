extends Pawn
class_name Player

@export var anim : AnimationPlayer

@onready var movement = $Movement
@onready var camera = $Camera
@onready var weapon_manager = $WeaponManager
@onready var life_bar = $CanvasLayer/MarginContainer/ProgressBar 

@export var axe_amount : int = 1

var _heal_delay_timer : float = 0.0
var _heal_tick_timer : float = 0.0

func decir_hola():
	print("hola")

func _ready():
	Globals.player = self
	
	
	life_bar.value = health

func _process(delta: float) -> void:
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
	super.take_damage(damage, attacker_pos, knockback_mult)
	
	_heal_delay_timer = 0.0
	_heal_tick_timer = 3.0
	
	if health > 0 and attacker_pos != Vector3.ZERO and knockback_mult > 0.0:
		movement.apply_knockback(attacker_pos, knockback_mult)
