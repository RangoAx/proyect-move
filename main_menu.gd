extends Node3D

# Referencias a los botones usando @onready
@onready var btn_nuevo_juego = $UI/MenuContainer/VBoxContainer/NuevoJuego
@onready var btn_ajustes = $UI/MenuContainer/VBoxContainer/Ajustes
@onready var btn_salir = $UI/MenuContainer/VBoxContainer/Salir

func _ready():
	# Conectar las señales "pressed" de los botones a sus respectivas funciones
	btn_nuevo_juego.pressed.connect(_on_nuevo_juego_pressed)
	btn_salir.pressed.connect(_on_salir_pressed)
	
	# Hacer que el botón "Nuevo Juego" tenga el foco por defecto
	# Esto es ideal para que el menú se pueda navegar con teclado o joystick
	btn_nuevo_juego.grab_focus()
	
	# Opcional: Asegurarnos de que el mouse sea visible al estar en el menú
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _on_nuevo_juego_pressed():
	# Cargamos el nivel principal. Usamos la ruta de la escena que ya tienes armada.
	get_tree().change_scene_to_file("res://toy_box.tscn")

func _on_ajustes_pressed():
	# Aquí luego abriremos el panel para brillo, volumen de sonido y música
	print("Abrir menú de ajustes (En construcción)")

func _on_salir_pressed():
	# Cierra la aplicación
	get_tree().quit()
