extends Area3D

@export_enum("Llave", "Hacha") var item_type: String = "Llave"

func _ready():
	collision_layer = 0
	collision_mask = 4 
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	if body.is_in_group("player"):
		if item_type == "Llave":
			Globals.has_church_key = true
			Globals.set_objective("Ve a la entrada de la Iglesia.")
		elif item_type == "Hacha":
			Globals.axe_level = 1 # O la lógica que active tu arma en el weapon_manager
			Globals.set_objective("Sobrevive al bosque.")
			
		queue_free()
