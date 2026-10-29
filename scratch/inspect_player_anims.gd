extends SceneTree

func _init() -> void:
    var p = load("res://assets/models/Animation personaje.glb").instantiate()
    var anim = p.find_child("AnimationPlayer", true, false) as AnimationPlayer
    for a in anim.get_animation_list():
        var anim_res = anim.get_animation(a)
        print("Anim: ", a, " length: ", anim_res.length, " tracks: ", anim_res.get_track_count())
        for t in range(anim_res.get_track_count()):
            print("  track: ", anim_res.track_get_path(t), " type: ", anim_res.track_get_type(t))
            if anim_res.track_get_type(t) == Animation.TYPE_METHOD:
                for k in range(anim_res.track_get_key_count(t)):
                    print("    method key at ", anim_res.track_get_key_time(t, k), ": ", anim_res.method_track_get_name(t, k))
    quit(0)
