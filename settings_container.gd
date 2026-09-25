extends MarginContainer

var master_bus_idx
@onready var volume_slider: HSlider = %VolumeSlider
@onready var brightness_slider: HSlider = %BrightnessSlider
@onready var btn_back: Button = %BtnBack

func _ready() -> void:
	master_bus_idx = AudioServer.get_bus_index("Master")
	
	btn_back.pressed.connect(_close_settings)
	volume_slider.value_changed.connect(_on_volume_changed)
	brightness_slider.value_changed.connect(_on_brightness_changed)

func _on_volume_changed(value: float) -> void:
	# Convierte valor lineal (0.0 a 1.0) a decibelios
	AudioServer.set_bus_volume_db(master_bus_idx, linear_to_db(value))
	AudioServer.set_bus_mute(master_bus_idx, value <= 0.001)

func _on_brightness_changed(value: float) -> void:
	# Ajusta la exposición global del viewport para controlar el brillo
	var env = get_viewport().world_3d.environment
	print(env)
	if env:
		env.tonemap_exposure = value

func _close_settings():
	visible = false
	$"../MenuContainer".visible = true

func _open_settings():
	visible = true
	$"../MenuContainer".visible = false
