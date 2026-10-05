extends Area3D

@export_multiline var texto: String
@export var duracion_segundos: float = 4.0 

@export_group("Desbloqueos de Tutorial")
@export var desbloquea_correr: bool = false
@export var desbloquea_dash: bool = false
@export var desbloquea_ataque: bool = false

var _ya_activado: bool = false

func _ready():
	collision_layer = 0
	collision_mask = 4 
	body_entered.connect(_mostrar_texto)

func _mostrar_texto(body):
	if _ya_activado: return
	
	if body.is_in_group("player"):
		_ya_activado = true
		set_deferred("monitoring", false)
		
		if desbloquea_correr: Globals.can_run = true
		if desbloquea_dash: Globals.can_dash = true
		if desbloquea_ataque: Globals.can_attack = true
		
		Globals.show_announcement(texto, duracion_segundos)
		queue_free()
