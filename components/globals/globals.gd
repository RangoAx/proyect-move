extends Node

var player

signal fragments_updated(total: int, added_amount: int)
signal weapon_swapped(weapon_name: String)
var has_church_key: bool = false
var has_axe : bool = false
signal objective_updated(new_text: String)
signal upgrade_purchased(stat_name: String, new_level: int)

func set_objective(text: String):
	objective_updated.emit(text)

var fragments : int = 0
var knife_level : int = 1
var axe_level : int = 1
var player_level : int = 1

var cost_level_2 : int = 75
var cost_level_3 : int = 150

var can_run: bool = true
var can_dash: bool = true
var can_attack: bool = true

func reset_tutorial_locks():
	can_run = true
	can_dash = true
	can_attack = true

func add_fragments(amount: int):
	fragments += amount
	fragments_updated.emit(fragments, amount)

func upgrade_knife() -> bool:
	return _process_upgrade("knife_level")

func upgrade_axe() -> bool:
	return _process_upgrade("axe_level")

func upgrade_player() -> bool:
	var success = _process_upgrade("player_level")
	if success:
		_apply_player_health_upgrade()
	return success

func _process_upgrade(stat_name: String) -> bool:
	var current_level = get(stat_name)
	var cost = cost_level_2 if current_level == 1 else cost_level_3
	
	if current_level < 3 and fragments >= cost:
		fragments -= cost
		var new_level = current_level + 1
		set(stat_name, new_level)
		if stat_name == "player_level":
			_apply_player_health_upgrade()
		fragments_updated.emit(fragments, -cost)
		upgrade_purchased.emit(stat_name, new_level)
		return true
	return false

func _apply_player_health_upgrade():
	if not player:
		return
	if player_level == 2:
		player.max_health = 150.0 # Nivel 2
	elif player_level == 3:
		player.max_health = 200.0 # Nivel 3
	player.health = player.max_health
	if "life_bar" in player and is_instance_valid(player.life_bar):
		player.life_bar.max_value = player.max_health
		player.life_bar.value = player.health
	
var _msg_id: int = 0

func show_announcement(text: String, duration: float = 5.0) -> void:
	if not player:
		return
	var label = player.get_node_or_null("HUD/TutorialLabel")
	if not label:
		return
		
	_msg_id += 1
	var current_id = _msg_id
	
	label.text = text
	label.visible = true
	
	if duration > 0.0:
		await get_tree().create_timer(duration).timeout
		# Solo lo oculta si ningún mensaje posterior tomó el control
		if current_id == _msg_id and is_instance_valid(label):
			label.visible = false

func _process(delta: float) -> void:
	if Input.is_key_pressed(KEY_F12):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
