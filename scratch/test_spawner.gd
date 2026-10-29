extends SceneTree

func _init() -> void:
    print("Testing ZoneSpawner script compilation...")
    var spawner_script = load("res://components/world/zone_spawner.gd") as GDScript
    if not spawner_script:
        printerr("Failed to load zone_spawner.gd")
        quit(1)
        return
    var spawner = spawner_script.new()
    print("ZoneSpawner initialized without errors!")
    spawner.free()
    quit(0)

