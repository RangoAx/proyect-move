extends RigidBody3D

@onready var pickup_area = $PickupHitbox
@onready var hit_area = $Hitbox
@export var damage : float = 75.0

var thrower : Node3D = null
# ya fue golpeado
var hitted : bool = false



func _physics_process(delta):
	#hacha agarrable
	for body in pickup_area.get_overlapping_bodies():
		if body is CharacterBody3D and body == Globals.player:
			if Input.is_action_just_pressed("interact") and Globals.player.axe_amount < 2: 
				Globals.player.axe_amount += 1
				queue_free()

func _on_hitbox_body_entered(body: Node3D) -> void:
	print("hitbox tocó: ", body.name)
	if hitted:
		return
	if body == thrower:
		return
	#notas: para hacer que clave mejor, achique la hitbox al filo del hacha
	if linear_velocity.length() > 1.5: # solo se clava si esta yendo rapido, no tiene sentido que se clave mientras rueda por el piso.
		freeze = true # cancela todas sus fisicas
		reparent(body) # cambia su parent al body, para que se mueva con este
	if body is Pawn and linear_velocity.length() > 4.0:
		body.take_damage(damage, global_position, 0.3) 
		hitted = true
