extends Area3D

@export_file("*.tscn") var church_insides_scene: String = "res://levels/map_1/church_insides.tscn"

var _loading: bool = false

func _ready() -> void:
	collision_layer = 0
	collision_mask = 4 # Detecta solo al jugador
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node3D) -> void:
	if _loading:
		return
		
	if body.is_in_group("player"):
		if Globals.has_church_key:
			_loading = true
			Globals.set_objective("Mas despacio profe todavia no llego a hacer el interior de la iglesia.")
			
			#if ResourceLoader.exists(church_insides_scene):
				#get_tree().change_scene_to_file(church_insides_scene)
			#else:
				#push_error("No se encontró la escena interior en: ", church_insides_scene)
		else:
			# Si intenta entrar sin llave, actualiza el objetivo y le avisa al centro
			Globals.set_objective("Consigue la llave en el pueblo.")
			Globals.show_announcement("La puerta está cerrada con candado. Necesitas la llave.", 4.0)
