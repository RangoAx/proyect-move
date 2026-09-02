@icon("res://assets/textures/icons/pawn.svg")
extends CharacterBody3D
class_name Pawn

@export var invulnerable : bool = false
@export var floating : bool = false

var max_health : float = 100.0
var health : float = max_health

func _physics_process(delta):
	if not floating:
		if not is_on_floor():
			velocity += get_gravity() * delta
		else:
			velocity.y = 0
	
	if health <= 0 and not invulnerable: die()

func die():
	queue_free()

func take_damage(damage : float, attacker_pos : Vector3 = Vector3.ZERO, knockback_mult : float = 1.0):
	if not invulnerable:
		health -= damage
