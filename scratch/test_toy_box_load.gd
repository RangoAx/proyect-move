extends SceneTree

func _init() -> void:
    print("Testing toy_box.tscn loading...")
    var packed = load("res://levels/map_1/toy_box.tscn") as PackedScene
    if not packed:
        printerr("Failed to load toy_box.tscn!")
        quit(1)
        return
    print("toy_box.tscn loaded successfully!")
    quit(0)

