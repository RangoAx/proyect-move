extends Area3D

@export var velocidad_rotacion: float = 2.0
@export var altura_flotacion: float = 0.25
@export var velocidad_flotacion: float = 3.0

var _tiempo_pasado: float = 0.0
var _y_inicial: float = 0.0

func _ready():
	# Configuración de físicas
	collision_layer = 0
	collision_mask = 4 
	body_entered.connect(_on_body_entered)
	
	# Guardamos la altura original en la que colocaste la llave en el mapa
	_y_inicial = global_position.y

func _process(delta: float):
	_tiempo_pasado += delta
	
	# Hace que la llave gire sobre sí misma (Eje Y)
	rotation.y += velocidad_rotacion * delta
	
	# Hace que suba y baje usando una onda matemática suave
	global_position.y = _y_inicial + (sin(_tiempo_pasado * velocidad_flotacion) * altura_flotacion)

func _on_body_entered(body: Node3D):
	if body.is_in_group("player"):
		Globals.has_church_key = true
		
		if Globals.has_method("set_objective"):
			Globals.set_objective("Ve a la entrada de la Iglesia.")
		
		queue_free()
