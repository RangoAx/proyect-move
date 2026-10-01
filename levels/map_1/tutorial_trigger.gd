extends Area3D

@export_multiline var texto: String
@export var duracion_segundos: float = 0.0 

@export_group("Desbloqueos de Tutorial")
@export var desbloquea_correr: bool = false
@export var desbloquea_dash: bool = false
@export var desbloquea_ataque: bool = false

func _ready():
	collision_layer = 0
	collision_mask = 4 
	body_entered.connect(_mostrar_texto)
	body_exited.connect(_ocultar_texto)

func _mostrar_texto(body):
	if body is Player:
		# Ahora cada habilidad se desbloquea de forma independiente
		if desbloquea_correr:
			Globals.can_run = true
		if desbloquea_dash:
			Globals.can_dash = true
		if desbloquea_ataque:
			Globals.can_attack = true
			
		var hud = body.get_node_or_null("HUD/TutorialLabel")
		if hud:
			hud.text = texto
			hud.visible = true
			
			if duracion_segundos > 0:
				await get_tree().create_timer(duracion_segundos).timeout
				if is_instance_valid(hud):
					hud.visible = false
				queue_free()

func _ocultar_texto(body):
	if body is Player and duracion_segundos <= 0:
		var hud = body.get_node_or_null("HUD/TutorialLabel")
		if hud:
			hud.visible = false
		queue_free()
