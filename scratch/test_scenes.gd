@tool
extends SceneTree

func _init():
	print("Checking scenes...")
	for s in ["res://components/world/cabin.tscn", "res://components/world/barricade.tscn", "res://components/world/tombstone.tscn", "res://components/world/fence.tscn"]:
		var res = load(s)
		print(s, ":", res)
	quit()

