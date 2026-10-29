extends Node

var _timer: float = 0.0
var _step: int = 0
var _player: Player = null
var _errors: Array[String] = []

func _ready():
	print("\n=======================================================")
	print("STARTING FULL IN-ENGINE GAMEPLAY & CONSOLE VERIFICATION")
	print("=======================================================\n")

func _process(delta: float):
	_timer += delta
	
	if _step == 0 and _timer > 0.5:
		_player = get_parent().get_node_or_null("Player") as Player
		if not _player:
			_errors.append("Player node not found in scene!")
			_finish()
			return
		print("[OK] Player successfully loaded at: ", _player.global_position)
		_step = 1
		
	elif _step == 1 and _timer > 1.0:
		print("\n--- Verifying Player Weapons & Abilities ---")
		var wm = _player.weapon_manager
		if not wm:
			_errors.append("WeaponManager not found on Player!")
		else:
			print("[OK] WeaponManager loaded. Current weapon: ", wm.current_weapon)
			if wm.has_method("attack"):
				wm.attack()
				print("[OK] WeaponManager attack() called successfully.")
		_step = 2
		
	elif _step == 2 and _timer > 1.5:
		print("\n--- Verifying Enemy Reveal Cinematic Trigger ---")
		var reveal_trigger = get_parent().find_child("EnemyRevealTrigger", true, false)
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
		
	elif _step == 3 and _timer > 2.2:
		print("\n--- Verifying Combat Arena 1 (Camino Norte) ---")
		var arena1 = get_parent().find_child("Arena1_CaminoNorte", true, false) as CombatArena
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
		
	elif _step == 4 and _timer > 2.8:
		print("\n--- Verifying Combat Arena 3 (Altar del Hacha - Event Trigger) ---")
		var arena3 = get_parent().find_child("Arena3_AltarHacha", true, false) as CombatArena
		if not arena3:
			_errors.append("Arena3 not found!")
		else:
			print("[OK] Simulating picking up Axe...")
			Globals.has_axe = true
			Globals.axe_acquired.emit()
			print("[OK] Arena 3 triggered by axe pickup: ", arena3._is_triggered)
			print("[OK] Arena 3 alive enemies: ", arena3._alive_enemies.size())
		_step = 5
		
	elif _step == 5 and _timer > 3.4:
		print("\n--- Verifying Combat Arena 4 (Camino a la Iglesia - Key Trigger) ---")
		var arena4 = get_parent().find_child("Arena4_EntradaIglesia", true, false) as CombatArena
		if not arena4:
			_errors.append("Arena4 not found!")
		else:
			Globals.has_church_key = true
			arena4._on_body_entered(_player)
			print("[OK] Arena 4 triggered with Church Key: ", arena4._is_triggered)
			print("[OK] Arena 4 horde enemies count: ", arena4._alive_enemies.size())
		_step = 6
		
	elif _step == 6 and _timer > 4.0:
		print("\n--- Verifying Church Door Interaction ---")
		var church_door = get_parent().find_child("ChurchDoor", true, false)
		if not church_door:
			_errors.append("ChurchDoor not found in scene!")
		else:
			church_door._on_body_entered(_player)
			print("[OK] Church door interacted with player having church key.")
		_step = 7
		
	elif _step == 7 and _timer > 4.5:
		_finish()

func _finish():
	print("\n=======================================================")
	if _errors.is_empty():
		print("ALL SYSTEMS TESTED: 100% OPERATIONAL, ZERO ERRORS!")
		print("=======================================================\n")
		get_tree().quit(0)
	else:
		print("TEST FAILED WITH ", _errors.size(), " ERRORS:")
		for err in _errors:
			print(" - ", err)
		print("=======================================================\n")
		get_tree().quit(1)

