extends SceneTree

func _init() -> void:
    print("Testing CircularFogWall instantiation...")
    var fog_script = load("res://components/world/circular_fog_wall.gd") as GDScript
    if not fog_script:
        printerr("Failed to load circular_fog_wall.gd")
        quit(1)
        return
    var fog_wall = fog_script.new()
    var root = Node3D.new()
    root.add_child(fog_wall)
    fog_wall.setup(Vector3(10, 0, 10), 18.0)
    print("CircularFogWall instantiated with collision and meshes successfully!")
    fog_wall.activate()
    print("Activated fog wall successfully!")
    fog_wall.dissolve()
    print("Dissolved fog wall successfully!")
    root.free()
    quit(0)

