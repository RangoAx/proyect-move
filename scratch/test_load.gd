@tool
extends SceneTree

func _init():
	print("Checking resource loading...")
	var audio = load("res://assets/audio/ringing.wav")
	print("ringing.wav:", audio)
	var cabin = load("res://assets/models/world/cabin.glb")
	print("cabin.glb:", cabin)
	quit()

