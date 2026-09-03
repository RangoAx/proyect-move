extends Control

func _on_reanudar_button_pressed() -> void:
	visible = !visible
	$AbilityMenu.visible = false
	
	toggle_level_pause()
	if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	else:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func toggle_level_pause():
	get_tree().paused = !get_tree().paused

#func _on_settings_button_pressed() -> void:
	#var settings_menu = get_node("/root/GUI/SettingsMenu")
	#settings_menu.visible = !settings_menu.visible
	#
	#if settings_menu.visible:
		##print("se debería haber abierto el menú de ajustes")
		#settings_menu.VideoSettings.update_resolution_button_values()


#func _on_quit_button_pressed() -> void:
	#var confirm_quit = get_node("/root/GUI/ConfirmQuit")
	#confirm_quit.visible = !confirm_quit.visible

func _process(_delta: float) -> void:
	
	#var settings_menu = get_node("/root/GUI/SettingsMenu")
	#var confirm_quit = get_node("/root/GUI/ConfirmQuit")
	#
	#if confirm_quit.visible:
		#confirm_quit.visible = !confirm_quit.visible
	
	#if settings_menu.visible and not is_instance_valid(Globales.main_menu):
		#settings_menu.visible = !settings_menu.visible
	if Input.is_action_just_pressed("pausa"):
		_on_reanudar_button_pressed()


func _on_ability_pressed() -> void:
	$AbilityMenu.show() 
	


func _on_quit_button_pressed() -> void:
	get_tree().change_scene_to_file("res://components/ui/menu_principal.tscn")
