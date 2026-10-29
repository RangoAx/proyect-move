extends Node3D

func _ready() -> void:
    print("=== Testing Fog Encounter System ===")
    
    # Create dummy player
    var player = CharacterBody3D.new()
    player.name = "Player"
    player.add_to_group("player")
    player.position = Vector3(20, 0, 22)
    add_child(player)
    
    # Register in Globals if present
    if has_node("/root/Globals"):
        var g = get_node("/root/Globals")
        g.player = player
    
    # Create ZoneSpawner
    var spawner_script = load("res://components/world/zone_spawner.gd") as GDScript
    var spawner = spawner_script.new() as ZoneSpawner
    spawner.name = "TestCombatZone"
    spawner.zone_name = "Zona Prueba"
    spawner.enable_circular_fog_wall = true
    spawner.fog_wall_radius = 18.0
    spawner.can_respawn = false
    
    # Add dummy enemy scenes
    var enemy_scene = load("res://enemies/enemy_fist.tscn") as PackedScene
    var scenes: Array[PackedScene] = [enemy_scene, enemy_scene]
    spawner.enemy_scenes = scenes
    
    # Add markers
    var m1 = Marker3D.new()
    m1.position = Vector3(5, 0, 5)
    spawner.add_child(m1)
    
    var m2 = Marker3D.new()
    m2.position = Vector3(-6, 0, -4)
    spawner.add_child(m2)
    
    add_child(spawner)
    
    # Trigger zone
    print("Triggering zone encounter...")
    spawner._start_zone()
    
    # Verify fog wall creation
    var fog_wall: CircularFogWall = null
    for child in get_children():
        if child is CircularFogWall:
            fog_wall = child
            break
            
    if not fog_wall:
        printerr("FAIL: CircularFogWall was not created!")
        get_tree().quit(1)
        return
        
    print("PASS: CircularFogWall spawned at: ", fog_wall.global_position)
    var dist_to_player = fog_wall.global_position.distance_to(player.global_position)
    print("Distance from fog wall center to player: ", dist_to_player)
    if dist_to_player > 0.1:
        printerr("FAIL: Fog wall not centered on player!")
        get_tree().quit(1)
        return
        
    if not fog_wall.is_active:
        printerr("FAIL: Fog wall is not active!")
        get_tree().quit(1)
        return
    print("PASS: Fog wall is active with radius: ", fog_wall.radius)
    
    # Verify enemies spawned
    print("Alive enemies count: ", spawner._alive_enemies.size())
    if spawner._alive_enemies.size() != 2:
        printerr("FAIL: Expected 2 enemies, got: ", spawner._alive_enemies.size())
        get_tree().quit(1)
        return
    print("PASS: All enemies spawned inside arena!")
    
    # Simulate defeating 1st enemy
    var enemy1 = spawner._alive_enemies[0]
    print("Defeating 1st enemy...")
    enemy1.queue_free()
    spawner._on_enemy_tree_exited(enemy1)
    
    if not fog_wall.is_active or fog_wall.is_dissolving:
        printerr("FAIL: Fog wall dissolved prematurely before last enemy was defeated!")
        get_tree().quit(1)
        return
    print("PASS: Fog wall remains active while enemies remain!")
    
    # Simulate defeating 2nd (last) enemy
    var enemy2 = spawner._alive_enemies[0]
    print("Defeating 2nd (last) enemy...")
    enemy2.queue_free()
    spawner._on_enemy_tree_exited(enemy2)
    
    if not fog_wall.is_dissolving:
        printerr("FAIL: Fog wall did not start dissolving after last enemy was defeated!")
        get_tree().quit(1)
        return
    print("PASS: Fog wall dissolved upon last enemy defeat!")
    
    print("=== All Fog Encounter tests PASSED successfully! ===")
    get_tree().quit(0)
