extends Node

var player

var scrap_amount : int = 0

signal fragments_updated(total: int, added_amount: int)
signal weapon_swapped(weapon_name: String)

var fragments : int = 0
var knife_level : int = 1
var axe_level : int = 1
var player_level : int = 1

var cost_level_2 : int = 50
var cost_level_3 : int = 100

func add_fragments(amount: int):
	fragments += amount
	# Trigger UI update signal here for the 2-second notification

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
		set(stat_name, current_level + 1)
		return true
	return false

func _apply_player_health_upgrade():
	if player_level == 2:
		player.max_health = 150
	elif player_level == 3:
		player.max_health = 200
	player.health = player.max_health
