extends Control


func _on_nuevo_juego_pressed() -> void:
	get_tree().change_scene_to_file("res://toy_box.tscn")


func _on_salir_del_juego_pressed() -> void:
	get_tree().quit()
