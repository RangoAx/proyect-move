extends Node3D

@onready var boss = $LumberjackEnemy
@onready var ending_ui = $EndingCanvas/EndingControl
@onready var fade_rect = $EndingCanvas/EndingControl/FadeRect
@onready var lore_label = $EndingCanvas/EndingControl/VBox/LoreLabel
@onready var credits_label = $EndingCanvas/EndingControl/VBox/CreditsLabel
@onready var btn_menu = $EndingCanvas/EndingControl/VBox/BtnMainMenu

func _ready() -> void:
	if ending_ui:
		ending_ui.visible = false
	if btn_menu:
		btn_menu.pressed.connect(_on_menu_pressed)
	if boss:
		boss.boss_defeated.connect(trigger_ending)

func trigger_ending() -> void:
	if not ending_ui or not fade_rect:
		return
		
	ending_ui.visible = true
	fade_rect.modulate.a = 0.0
	lore_label.modulate.a = 0.0
	credits_label.modulate.a = 0.0
	btn_menu.modulate.a = 0.0
	btn_menu.disabled = true
	
	# 1. Fundido a negro progresivo (GDD: pantalla en negro poco a poco)
	var tween = create_tween()
	tween.tween_property(fade_rect, "modulate:a", 1.0, 3.0)
	
	# 2. Texto de conclusión de Lore
	tween.tween_interval(1.0)
	tween.tween_property(lore_label, "modulate:a", 1.0, 2.0)
	tween.tween_interval(4.5)
	
	# 3. Créditos del equipo (GDD)
	tween.tween_property(credits_label, "modulate:a", 1.0, 2.0)
	tween.tween_property(btn_menu, "modulate:a", 1.0, 1.0)
	tween.tween_callback(func():
		btn_menu.disabled = false
		btn_menu.grab_focus()
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	)

func _on_menu_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")

