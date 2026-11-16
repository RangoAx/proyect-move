extends Area3D

@export var tp_location : Vector3 = Vector3(-10.3,-47.7,38.7)


func _ready() -> void:
	collision_layer = 0
	collision_mask = 4 # Detecta solo al jugador
	Globals.has_church_key = true
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node3D) -> void:
		
	if body.is_in_group("player"):
		if Globals.has_church_key:
			Globals.set_objective("Mas despacio profe todavia no llego a hacer el interior de la iglesia.")
			
			Globals.player.position = tp_location
			Globals.set_objective("Consigue la llave en el pueblo.")
			Globals.show_announcement("La puerta está cerrada con candado. Necesitas la llave.", 4.0)
