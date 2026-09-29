extends Node3D

# AÑADIDO: Referencia al contenedor padre de los botones
@onready var menu_botones = $UI/MenuContainer/VBoxContainer

@onready var btn_nuevo_juego = $UI/MenuContainer/VBoxContainer/NuevoJuego
@onready var btn_salir = $UI/MenuContainer/VBoxContainer/Salir
@onready var lore_screen = $UI/MenuContainer/LoreScreen
@onready var btn_continuar_lore = $UI/MenuContainer/LoreScreen/Continuar

func _ready():
	lore_screen.visible = false
	btn_nuevo_juego.pressed.connect(_mostrar_lore)
	btn_continuar_lore.pressed.connect(_empezar_nivel)
	btn_salir.pressed.connect(_on_salir_pressed)
	btn_nuevo_juego.grab_focus()
	
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _mostrar_lore():
	lore_screen.visible = true
	menu_botones.visible = false # AÑADIDO: Oculta los botones del menú

func _empezar_nivel():
	get_tree().change_scene_to_file("res://toy_box.tscn")

func _on_salir_pressed():
	get_tree().quit()
