extends Area3D

@export var velocidad_rotacion: float = 2.0
@export var altura_flotacion: float = 0.25
@export var velocidad_flotacion: float = 3.0

var _tiempo_pasado: float = 0.0
var _y_inicial: float = 0.0
var _ya_recogido: bool = false 

func _ready():
	collision_layer = 0
	collision_mask = 4 
	body_entered.connect(_on_body_entered)
	_y_inicial = global_position.y

func _process(delta: float):
	if _ya_recogido: return
	_tiempo_pasado += delta
	rotation.y += velocidad_rotacion * delta
	global_position.y = _y_inicial + (sin(_tiempo_pasado * velocidad_flotacion) * altura_flotacion)

func _on_body_entered(body: Node3D):
	if _ya_recogido: return
		
	if body.is_in_group("player"):
		_ya_recogido = true
		Globals.has_axe = true
		
		
		# Actualiza la misión en la esquina
		if not Globals.has_church_key:
			Globals.set_objective("Explora el pueblo y busca la llave.")
		else:
			Globals.set_objective("Ve a la entrada de la Iglesia.")
			
		# Anuncio central garantizado sin interferencias por 6 segundos
		Globals.show_announcement("¡NUEVA ARMA: HACHA ARROJADIZA!\nPuedes usar los fragmentos conseguidos en batalla para mejorar tus armas en el Menú de Pausa.", 6.0)
		
		queue_free()
