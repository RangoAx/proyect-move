extends SceneTree

func _init() -> void:
    var p = load("res://assets/models/Animation personaje.glb").instantiate()
    var anim = p.find_child("AnimationPlayer", true, false) as AnimationPlayer
    for a in ["Ataque1", "Ataque2", "Ataque3"]:
        var anim_res = anim.get_animation(a)
        print("=== Anim: ", a, " length: ", anim_res.length, " ===")
        for t in range(anim_res.get_track_count()):
            if anim_res.track_get_type(t) == Animation.TYPE_METHOD:
                print("  Track path: ", anim_res.track_get_path(t))
                for k in range(anim_res.track_get_key_count(t)):
                    print("    key at ", anim_res.track_get_key_time(t, k), ": ", anim_res.method_track_get_name(t, k))
    quit(0)
