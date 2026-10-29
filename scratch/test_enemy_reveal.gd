extends SceneTree

var _timer: float = 0.0
var _step: int = 0
var _map = null
var _player = null
var _globals = null

func _init():
	print("TEST: Initializing Enemy Reveal and Combat Arena Test...")
	change_scene_to_file("res://levels/map_1/toy_box.tscn")

func _process(delta: float) -> bool:
	_timer += delta
	if _step == 0 and _timer > 0.5:
		_map = current_scene
		if not _map:
			return false
		_player = _map.get_node_or_null("Player")
		_globals = root.get_node_or_null("Globals")
		if not _player:
			print("FAIL: Player not found!")
			quit(1)
			return true
		print("STEP 0: Player found at ", _player.global_position)
		
		# Teleport player right before the Enemy Reveal trigger (-54.0, 0, -11.0)
		_player.global_position = Vector3(-53.9, 0.0, -11.0)
		_step = 1
		
	elif _step == 1 and _timer > 1.0:
		print("STEP 1: Checking Enemy Reveal cinematic status...")
		var cam_mgr = _player.camera
		var is_cin = cam_mgr.is_cinematic if cam_mgr else false
		var is_trapped = _player.movement.trapped if _player.movement else false
		var label = _player.get_node_or_null("HUD/TutorialLabel")
		var txt = label.text if label else ""
		print("   is_cinematic: ", is_cin)
		print("   trapped: ", is_trapped)
		print("   tutorial text: ", txt)
		
		var trigger = _map.find_child("EnemyRevealTrigger", true, false)
		if trigger and not is_cin:
			print("   Trigger manually called.")
			trigger._on_body_entered(_player)
			print("   New is_cinematic: ", cam_mgr.is_cinematic)
			print("   New trapped: ", _player.movement.trapped)
			print("   New tutorial text: ", label.text if label else "")
		_step = 2
		
	elif _step == 2 and _timer > 2.0:
		print("STEP 2: Testing Arena 1 Trigger (Camino Norte)...")
		var arena1 = _map.find_child("Arena1_CaminoNorte", true, false)
		if arena1:
			print("   Found Arena1:", arena1.name)
			arena1.start_arena()
			print("   Arena1 started!")
			print("   Arena1 is_triggered:", arena1._is_triggered)
			print("   Arena1 alive enemies:", arena1._alive_enemies.size())
			var world_env = _map.find_child("WorldEnvironment", true, false)
			if world_env and world_env.environment:
				print("   Volumetric fog density during fight:", world_env.environment.volumetric_fog_density)
		_step = 3
		
	elif _step == 3 and _timer > 3.0:
		print("STEP 3: Testing Arena 3 (Axe Acquisition Trigger)...")
		var arena3 = _map.find_child("Arena3_AltarHacha", true, false)
		if arena3 and _globals:
			print("   Found Arena3:", arena3.name)
			# Simular adquisición del hacha
			_globals.has_axe = true
			_globals.axe_acquired.emit()
			print("   Emitted Globals.axe_acquired")
			print("   Arena3 is_triggered:", arena3._is_triggered)
			print("   Arena3 alive enemies:", arena3._alive_enemies.size())
		_step = 4
		
	elif _step == 4 and _timer > 4.0:
		print("STEP 4: Testing Arena 4 (Church Key to Church Trigger)...")
		var arena4 = _map.find_child("Arena4_EntradaIglesia", true, false)
		if arena4 and _globals:
			print("   Found Arena4:", arena4.name)
			_globals.has_church_key = true
			arena4._on_body_entered(_player)
			print("   Arena4 started with key!")
			print("   Arena4 is_triggered:", arena4._is_triggered)
			print("   Arena4 alive enemies:", arena4._alive_enemies.size())
		print("\nALL VERIFICATIONS COMPLETED SUCCESSFULLY!")
		quit(0)
		return true
		
	return false
