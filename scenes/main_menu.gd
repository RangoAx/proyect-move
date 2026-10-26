extends Node3D

@onready var menu_botones: VBoxContainer = $UI/MenuContainer/VBoxContainer
@onready var title_container: VBoxContainer = $UI/MenuContainer/TitleContainer
@onready var btn_nuevo_juego: Button = $UI/MenuContainer/VBoxContainer/NuevoJuego
@onready var btn_salir: Button = $UI/MenuContainer/VBoxContainer/Salir
@onready var lore_screen: Control = $UI/MenuContainer/LoreScreen
@onready var btn_continuar_lore: Button = find_child("BtnContinuarLore", true, false) as Button
@onready var dir_light: DirectionalLight3D = $Background/DirectionalLight3D
@onready var lightning_overlay: ColorRect = $UI/LightningOverlay

var _thunder_timer: float = 3.0
var _base_light_energy: float = 0.35

func _ready() -> void:
	lore_screen.visible = false
	menu_botones.visible = true
	title_container.visible = true
	if lightning_overlay:
		lightning_overlay.modulate.a = 0.0
	
	if dir_light:
		dir_light.light_energy = _base_light_energy
		
	btn_nuevo_juego.pressed.connect(_mostrar_lore)
	if btn_continuar_lore:
		btn_continuar_lore.pressed.connect(_empezar_nivel)
	btn_salir.pressed.connect(_on_salir_pressed)
	btn_nuevo_juego.grab_focus()
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	_schedule_next_thunder()

func _process(delta: float) -> void:
	_thunder_timer -= delta
	if _thunder_timer <= 0.0:
		_trigger_thunder()
		_schedule_next_thunder()

func _schedule_next_thunder() -> void:
	_thunder_timer = randf_range(4.5, 9.0)

func _trigger_thunder() -> void:
	if not dir_light or not lightning_overlay:
		return
		
	var tween = create_tween()
	# Primer destello rápido
	tween.tween_property(dir_light, "light_energy", 3.0, 0.05)
	tween.parallel().tween_property(lightning_overlay, "modulate:a", 0.45, 0.05)
	# Breve atenuación
	tween.tween_property(dir_light, "light_energy", 0.8, 0.04)
	tween.parallel().tween_property(lightning_overlay, "modulate:a", 0.15, 0.04)
	# Segundo destello potente
	tween.tween_property(dir_light, "light_energy", 4.5, 0.08)
	tween.parallel().tween_property(lightning_overlay, "modulate:a", 0.6, 0.08)
	# Decaimiento suave
	tween.tween_property(dir_light, "light_energy", _base_light_energy, 0.6).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(lightning_overlay, "modulate:a", 0.0, 0.6).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

func _mostrar_lore() -> void:
	lore_screen.visible = true
	menu_botones.visible = false
	title_container.visible = false
	if btn_continuar_lore:
		btn_continuar_lore.grab_focus()

func _empezar_nivel() -> void:
	get_tree().change_scene_to_file("res://levels/map_1/toy_box.tscn")

func _on_salir_pressed() -> void:
	get_tree().quit()
