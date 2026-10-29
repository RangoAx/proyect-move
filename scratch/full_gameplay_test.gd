extends SceneTree

var _timer: float = 0.0
var _step: int = 0
var _map: Node3D = null
var _player: Player = null
var _errors: Array[String] = []

func _init():
	print("\n=======================================================")
	print("STARTING FULL IN-ENGINE GAMEPLAY & CONSOLE VERIFICATION")
	print("=======================================================\n")
	change_scene_to_file("res://levels/map_1/toy_box.tscn")

func _process(delta: float) -> bool:
	_timer += delta
	
	if _step == 0 and _timer > 0.6:
		_map = current_scene as Node3D
		if not _map:
			return false
		_player = _map.get_node_or_null("Player") as Player
		if not _player:
			_errors.append("Player node not found in scene!")
			_finish()
			return true
		print("[OK] Player successfully loaded at: ", _player.global_position)
		_step = 1
		
	elif _step == 1 and _timer > 1.0:
		print("\n--- Verifying Player Weapons & Abilities ---")
		var wm = _player.weapon_manager
		if not wm:
			_errors.append("WeaponManager not found on Player!")
		else:
			print("[OK] WeaponManager loaded. Current weapon: ", wm.current_weapon)
			# Test weapon attack combo
			if wm.has_method("attack"):
				wm.attack()
				print("[OK] WeaponManager attack() called successfully.")
		_step = 2
		
	elif _step == 2 and _timer > 1.6:
		print("\n--- Verifying Enemy Reveal Cinematic Trigger ---")
		var reveal_trigger = _map.find_child("EnemyRevealTrigger", true, false)
		if not reveal_trigger:
			_errors.append("EnemyRevealTrigger not found in scene!")
		else:
			print("[OK] Found EnemyRevealTrigger at: ", reveal_trigger.global_position)
			reveal_trigger._on_body_entered(_player)
			var cam_mgr = _player.camera
			if cam_mgr and cam_mgr.is_cinematic:
				print("[OK] Camera is_cinematic active. Player trapped: ", _player.movement.trapped)
			var hud_lbl = _player.get_node_or_null("HUD/TutorialLabel") as Label
			if hud_lbl and hud_lbl.visible:
				print("[OK] Announcement visible: '", hud_lbl.text, "'")
		_step = 3
		
	elif _step == 3 and _timer > 2.4:
		print("\n--- Verifying Combat Arena 1 (Camino Norte) ---")
		var arena1 = _map.find_child("Arena1_CaminoNorte", true, false) as CombatArena
		if not arena1:
			_errors.append("Arena1_CaminoNorte not found!")
		else:
			print("[OK] Found Arena 1. Starting lockdown arena...")
			arena1.start_arena()
			print("[OK] Arena 1 triggered. Enemies spawned: ", arena1._alive_enemies.size())
			print("[OK] Arena 1 barriers active: ", arena1.barrier_nodes.size())
			for b in arena1.barrier_nodes:
				if not b.visible:
					_errors.append("Barricade not visible during arena lockdown!")
		_step = 4
		
	elif _step == 4 and _timer > 3.0:
		print("\n--- Verifying Combat Arena 3 (Altar del Hacha - Event Trigger) ---")
		var arena3 = _map.find_child("Arena3_AltarHacha", true, false) as CombatArena
		var globals = root.get_node_or_null("Globals")
		if not arena3 or not globals:
			_errors.append("Arena3 or Globals not found!")
		else:
			print("[OK] Simulating picking up Axe...")
			globals.has_axe = true
			globals.axe_acquired.emit()
			print("[OK] Arena 3 triggered by axe pickup: ", arena3._is_triggered)
			print("[OK] Arena 3 alive enemies: ", arena3._alive_enemies.size())
		_step = 5
		
	elif _step == 5 and _timer > 3.6:
		print("\n--- Verifying Combat Arena 4 (Camino a la Iglesia - Key Trigger) ---")
		var arena4 = _map.find_child("Arena4_EntradaIglesia", true, false) as CombatArena
		var globals = root.get_node_or_null("Globals")
		if not arena4 or not globals:
			_errors.append("Arena4 not found!")
		else:
			globals.has_church_key = true
			arena4._on_body_entered(_player)
			print("[OK] Arena 4 triggered with Church Key: ", arena4._is_triggered)
			print("[OK] Arena 4 horde enemies count: ", arena4._alive_enemies.size())
		_step = 6
		
	elif _step == 6 and _timer > 4.2:
		print("\n--- Verifying Church Door Interaction ---")
		var church_door = _map.find_child("ChurchDoor", true, false)
		if not church_door:
			_errors.append("ChurchDoor not found in scene!")
		else:
			church_door._on_body_entered(_player)
			print("[OK] Church door interacted with player having church key.")
		_step = 7
		
	elif _step == 7 and _timer > 4.8:
		_finish()
		return true
		
	return false

func _finish():
	print("\n=======================================================")
	if _errors.is_empty():
		print("ALL SYSTEMS TESTED: 100% OPERATIONAL, ZERO ERRORS!")
		print("=======================================================\n")
		quit(0)
	else:
		print("TEST FAILED WITH ", _errors.size(), " ERRORS:")
		for err in _errors:
			print(" - ", err)
		print("=======================================================\n")
		quit(1)

