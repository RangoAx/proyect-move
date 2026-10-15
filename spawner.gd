extends Area3D

var current_wave : int = 0

func _on_enemy_death() :
	pass

func is_wave_finished() -> bool:
	var finished : bool = true
	for child in get_children():
		if child is Enemy:
			finished = false
	return finished


@export var spawn_points : Array[Marker3D]
# te va a aparecer un array parecido a lo que hicimos con las llaves,
# que podes meter nodos Marker3D para poner los puntos de spawn de los enemigos


var ENEMY_SCENES : Dictionary = {
	"enemy_axe" = load("res://enemies/enemy_axe.tscn"),
	"enemy_fist" = load("res://enemies/enemy_fist.tscn"),
	"enemy_lumberjack" = load("res://enemies/enemy_lumberjack.tscn"),

	# las rutas son a modo de ejemplo, no se donde estan los enemigos en
	# los archivos de tu juego, aca pones todos los enemigos
}
# aca guardamos las escenas de los enemigos para copiar dentro del juego,
# a esto se le llama "instanciar".
#
# la lista que nosotros utilizamos aca es parecida a la que usamos anteriormente
# arriba y la clase pasada, pero en vez de ser item 1, item 2, etc...
# en vez de numeros le damos un nombre a cada item. Este tipo de lista se llama
# diccionario.

@export var waves : Array[PackedStringArray]
# aca vamos a poner que enemigos queremos spawnear, por ejemplo si queres que
# spawnee un enemigo con hacha y dos enemigos desarmados, pondrias 3 strings que
# digan:
#			0	enemy_axe
#			1	enemy_fist
#			2	enemy_fist

func _on_body_entered(_body = null):
	if  is_wave_finished() == false:
		return
	for enemy in waves[current_wave]:
		current_wave += 1
		
		var enemy_scene = ENEMY_SCENES[enemy]
		# vamos a agarrar el item con el nombre del enemigo que
		# queremos spawnear, que nos va a dar la escena de ese enemigo
		
		var enemy_node = enemy_scene.instantiate()
		# vamos a spawnear un nodo basado en la escena que nosotros elegimos recien
		
		add_child(enemy_node)
		# cuando creamos un nodo, esta cargado en la ram, pero no esta
		# en el juego (se podria decir que esta en el banco de suplentes)
		# asi que para que entre en el mundo hay que hacerlo hijo de algo
		# en este caso lo hacemos hijo del spawner
		
		var spawn_point = spawn_points.pick_random()
		# hago el spawnpoint un item random de la lista de spawnpoints
		
		enemy_node.global_position = spawn_point.global_position
		# hago que la posicion del enemigo spawneado sea la posicion
		# del spawnpoint
		enemy_node.tree_exiting.connect(_on_enemy_tree_exiting)

func _on_enemy_tree_exiting():
	_on_body_entered()
