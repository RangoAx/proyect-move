extends SceneTree

func _init() -> void:
    print("Testing FogVolume and shader_type fog in Godot 4...")
    var fog_volume = FogVolume.new()
    print("FogVolume class exists: ", fog_volume != null)
    print("FogVolume shape: ", fog_volume.shape)
    fog_volume.free()
    quit(0)

