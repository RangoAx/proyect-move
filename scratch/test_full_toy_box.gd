extends SceneTree

func _init() -> void:
    print("Testing full instantiation of toy_box.tscn...")
    var packed = load("res://levels/map_1/toy_box.tscn") as PackedScene
    if not packed:
        printerr("Failed to load toy_box.tscn")
        quit(1)
        return
    var inst = packed.instantiate()
    if not inst:
        printerr("Failed to instantiate toy_box.tscn")
        quit(1)
        return
    print("toy_box.tscn instantiated into memory successfully!")
    inst.free()
    quit(0)

