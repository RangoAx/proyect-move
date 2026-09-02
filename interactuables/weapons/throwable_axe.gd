extends RigidBody3D

@onready var hit_area = $Hitbox
@export var damage : float = 75.0

var thrower : Node3D = null
var hitted : bool = false



func _physics_process(delta):
	pass

func _on_hitbox_body_entered(body: Node3D) -> void:
	if hitted:
		return
	if body == thrower:
		return
	if linear_velocity.length() > 1.5: # solo se clava si esta yendo rapido, no tiene sentido que se clave mientras rueda por el piso.
		freeze = true # cancela todas sus fisicas
		reparent(body) # cambia su parent al body, para que se mueva con este
	if body is Pawn and linear_velocity.length() > 4.0:
		body.take_damage(damage, global_position, 0.3) 
		hitted = true
	await get_tree().create_timer(1.0).timeout
	queue_free()
