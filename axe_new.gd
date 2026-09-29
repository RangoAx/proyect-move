extends Area3D

@export var velocidad_rotacion: float = 2.0
@export var altura_flotacion: float = 0.25
@export var velocidad_flotacion: float = 3.0

var _tiempo_pasado: float = 0.0
var _y_inicial: float = 0.0

func _ready():
	collision_layer = 0
	collision_mask = 4 
	body_entered.connect(_on_body_entered)
	
	_y_inicial = global_position.y

func _process(delta: float):
	_tiempo_pasado += delta
	rotation.y += velocidad_rotacion * delta
	global_position.y = _y_inicial + (sin(_tiempo_pasado * velocidad_flotacion) * altura_flotacion)

func _on_body_entered(body: Node3D):
	if body.is_in_group("player"):
		Globals.has_axe = true
		
		if Globals.has_method("set_objective"):
			Globals.set_objective("Ve a la entrada de la Iglesia.")
		
		queue_free()
