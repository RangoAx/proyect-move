extends Control
class_name PauseMenu

@onready var main_card: PanelContainer = %MainCard
@onready var settings_card: PanelContainer = %SettingsCard
@onready var ability_menu: Control = $AbilityMenu

@onready var btn_resume: Button = %BtnResume
@onready var btn_ability: Button = %BtnAbility
@onready var btn_settings: Button = %BtnSettings
@onready var btn_main_menu: Button = %BtnQuit

@onready var volume_slider: HSlider = %VolumeSlider
@onready var brightness_slider: HSlider = %BrightnessSlider
@onready var sens_slider: HSlider = %SensSlider
@onready var btn_back: Button = %BtnBack

@onready var lbl_volume_val: Label = %LblVolumeVal
@onready var lbl_brightness_val: Label = %LblBrightnessVal
@onready var lbl_sens_val: Label = %LblSensVal

@export var main_menu_scene_path: String = "res://scenes/main_menu.tscn"

var master_bus_idx: int = 0

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false
	main_card.visible = true
	settings_card.visible = false
	ability_menu.visible = false
	
	master_bus_idx = AudioServer.get_bus_index("Master")
	
	# Conexiones de botones principales
	btn_resume.pressed.connect(resume_game)
	btn_ability.pressed.connect(_on_ability_pressed)
	btn_settings.pressed.connect(_open_settings)
	btn_main_menu.pressed.connect(_go_to_main_menu)
	
	# Conexiones de ajustes
	btn_back.pressed.connect(_close_settings)
	volume_slider.value_changed.connect(_on_volume_changed)
	brightness_slider.value_changed.connect(_on_brightness_changed)
	if sens_slider:
		sens_slider.value = Settings.mouse_sens if has_node("/root/Settings") else 1.0
		sens_slider.value_changed.connect(_on_sens_changed)
		_on_sens_changed(sens_slider.value)
	
	_on_volume_changed(volume_slider.value)
	_on_brightness_changed(brightness_slider.value)
	
	# Conexión del botón Volver del árbol de habilidades
	var ability_back_btn = ability_menu.find_child("BtnBack", true, false) as Button
	if ability_back_btn and not ability_back_btn.pressed.is_connected(_close_ability_menu):
		ability_back_btn.pressed.connect(_close_ability_menu)

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.is_pressed() and not event.is_echo():
		if event.keycode == KEY_ESCAPE or event.physical_keycode == KEY_ESCAPE:
			var vp := get_viewport()
			if vp:
				vp.set_input_as_handled()
			if visible:
				if settings_card.visible:
					_close_settings()
				elif ability_menu.visible:
					_close_ability_menu()
				else:
					resume_game()
			else:
				pause_game()

func pause_game() -> void:
	visible = true
	main_card.visible = true
	settings_card.visible = false
	ability_menu.visible = false
	get_tree().paused = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	btn_resume.grab_focus()

func resume_game() -> void:
	visible = false
	get_tree().paused = false
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _open_settings() -> void:
	main_card.visible = false
	settings_card.visible = true
	btn_back.grab_focus()

func _close_settings() -> void:
	settings_card.visible = false
	main_card.visible = true
	btn_settings.grab_focus()

func _on_ability_pressed() -> void:
	main_card.visible = false
	ability_menu.visible = true

func _close_ability_menu() -> void:
	ability_menu.visible = false
	main_card.visible = true
	btn_ability.grab_focus()

func _on_volume_changed(value: float) -> void:
	if lbl_volume_val:
		lbl_volume_val.text = "%d%%" % int(value)
	var linear = value / 100.0
	if linear <= 0.001:
		AudioServer.set_bus_mute(master_bus_idx, true)
	else:
		AudioServer.set_bus_mute(master_bus_idx, false)
		AudioServer.set_bus_volume_db(master_bus_idx, linear_to_db(linear))

func _on_brightness_changed(value: float) -> void:
	if lbl_brightness_val:
		lbl_brightness_val.text = "%.2fx" % value
	var cam = get_viewport().get_camera_3d()
	if cam and cam.environment:
		cam.environment.adjustment_enabled = true
		cam.environment.adjustment_brightness = value

func _on_sens_changed(value: float) -> void:
	if lbl_sens_val:
		lbl_sens_val.text = "%.1fx" % value
	if has_node("/root/Settings"):
		Settings.mouse_sens = value

func _go_to_main_menu() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file(main_menu_scene_path)
