extends SceneTree

func _init() -> void:
    var f = FileAccess.open("res://scratch/test_out.txt", FileAccess.WRITE)
    f.store_line("Testing FogVolume...")
    var fv = FogVolume.new()
    f.store_line("FogVolume created: " + str(fv != null))
    f.store_line("FogVolume shape: " + str(fv.shape))
    fv.free()
    f.close()
    quit(0)

