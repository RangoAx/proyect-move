extends Area3D

@export var dialogue_text: String = "Antonio: ¿Qué demonios son esas cosas...?"
@export var cinematic_duration: float = 3.2
@export var target_zone: ZoneSpawner

var _has_triggered: bool = false

func _ready() -> void:
	collision_layer = 0
	collision_mask = 4 # Detecta únicamente al jugador
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node3D) -> void:
	if _has_triggered:
		return
	if not body.is_in_group("player"):
		return
		
	_has_triggered = true
	set_deferred("monitoring", false)
	
	# Buscar al primer enemigo para enfocar
	var target_enemy: Node3D = null
	
	if target_zone and "_alive_enemies" in target_zone:
		for e in target_zone._alive_enemies:
			if is_instance_valid(e):
				target_enemy = e
				break
				
	if not target_enemy:
		var enemies = get_tree().get_nodes_in_group("Enemy")
		if enemies.is_empty():
			enemies = get_tree().get_nodes_in_group("enemy")
		var min_dist: float = 9999.0
		for e in enemies:
			if is_instance_valid(e) and e is Node3D:
				var d = body.global_position.distance_to(e.global_position)
				if d < min_dist and d < 30.0:
					min_dist = d
					target_enemy = e

	if target_enemy and "camera" in body and body.camera and body.camera.has_method("play_enemy_reveal"):
		body.camera.play_enemy_reveal(target_enemy, dialogue_text, cinematic_duration)
	else:
		Globals.show_announcement(dialogue_text, cinematic_duration)
		
	queue_free()

