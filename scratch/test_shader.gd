extends SceneTree

func _init() -> void:
    print("Testing circular fog wall shader compilation...")
    var shader = load("res://components/world/circular_fog_wall.gdshader") as Shader
    if not shader:
        printerr("Failed to load shader!")
        quit(1)
        return
    var mat = ShaderMaterial.new()
    mat.shader = shader
    mat.set_shader_parameter("fade_amount", 1.0)
    print("Shader loaded and parameters set successfully!")
    quit(0)

