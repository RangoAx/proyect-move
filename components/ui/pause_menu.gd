extends Control
class_name PauseMenu

@onready var main_options: VBoxContainer = %MainOptions
@onready var settings_options: VBoxContainer = %SettingsOptions
@onready var ability_menu: Control = $AbilityMenu

@onready var btn_resume: Button = %BtnResume
@onready var btn_settings: Button = %BtnSettings
@onready var btn_main_menu: Button = %BtnQuit

@onready var volume_slider: HSlider = %VolumeSlider
@onready var brightness_slider: HSlider = %BrightnessSlider
@onready var btn_back: Button = %BtnBack

@export var main_menu_scene_path: String = "res://scenes/main_menu.tscn"

var master_bus_idx: int = 0

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false
	main_options.visible = true
	settings_options.visible = false
	ability_menu.visible = false
	
	master_bus_idx = AudioServer.get_bus_index("Master")
	
	# Conexiones de botones principales
	btn_resume.pressed.connect(resume_game)
	btn_settings.pressed.connect(_open_settings)
	btn_main_menu.pressed.connect(_go_to_main_menu)
	
	# Conexiones de ajustes
	btn_back.pressed.connect(_close_settings)
	volume_slider.value_changed.connect(_on_volume_changed)
	brightness_slider.value_changed.connect(_on_brightness_changed)
	
	# Conexión del botón Volver del árbol de habilidades
	var ability_back_btn = ability_menu.get_node_or_null("BtnBack") as Button
	if ability_back_btn:
		ability_back_btn.pressed.connect(_close_ability_menu)

func _unhandled_input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("ui_cancel"): # ESC
		if visible:
			if settings_options.visible:
				_close_settings()
			elif ability_menu.visible:
				_close_ability_menu()
			else:
				resume_game()
		else:
			pause_game()

func pause_game() -> void:
	visible = true
	main_options.visible = true
	settings_options.visible = false
	ability_menu.visible = false
	get_tree().paused = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func resume_game() -> void:
	visible = false
	get_tree().paused = false
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _open_settings() -> void:
	main_options.visible = false
	settings_options.visible = true

func _close_settings() -> void:
	settings_options.visible = false
	main_options.visible = true

# --- GESTIÓN DEL MENÚ DE HABILIDADES ---
func _on_ability_pressed() -> void:
	main_options.visible = false
	ability_menu.visible = true

func _close_ability_menu() -> void:
	ability_menu.visible = false
	main_options.visible = true

func _on_volume_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(master_bus_idx, linear_to_db(value))
	AudioServer.set_bus_mute(master_bus_idx, value <= 0.001)

func _on_brightness_changed(value: float) -> void:
	var env = get_viewport().world_3d.environment
	if env:
		env.tonemap_exposure = value

func _go_to_main_menu() -> void:
	get_tree().paused = false
	if ResourceLoader.exists(main_menu_scene_path):
		get_tree().change_scene_to_file(main_menu_scene_path)
	else:
		push_error("No se encontró la escena del menú principal en: ", main_menu_scene_path)
