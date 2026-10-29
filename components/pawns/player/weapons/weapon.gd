extends Node
class_name Weapon
@onready var camera : CameraManager = $"../../Camera"
@onready var weapon_manager : WeaponManager = get_parent()
@onready var player : Player = get_parent().get_parent()

func aim_start():
	pass
	
func aim_end():
	camera.expected_length = camera.default_length
	camera.expected_offset = camera.default_offset

func aim_attack():
	pass

func enter():
	pass
	
func exit():
	pass

func attack():
	pass

var attack_buffered : bool = false
@export var attack_window : bool = false
var attack_follow : bool = false

func buffer_attack() -> void:
	attack_buffered = true
	attack_follow = true

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("attack") and attack_window:
		attack_follow = true

func play_attack_animation(animation : String, lag_amount:float):
	if attack_buffered:
		attack_follow = true
		attack_buffered = false
	else:
		attack_follow = false
	attack_window = true
	if not player.anim.has_animation(animation): printerr("Animacion no existe: %s" % animation) 
	player.anim.stop()
	player.anim.play(animation)
	await player.anim.animation_finished
	if attack_follow or attack_buffered:
		attack_buffered = false
		return true
	await get_tree().create_timer(lag_amount).timeout
	attack_window = false
	var res = attack_follow or attack_buffered
	attack_buffered = false
	return res
#
#func play_interruptible_animation(animation : StringName, startup : float = 0, action : StringName = "attack"):
	#var anim : AnimationPlayer = player.anim
	#anim.play(animation)
	#await get_tree().create_timer(startup).timeout
	#while true:
		#if not anim.is_playing():
			#return true
		#elif Input.is_action_just_pressed(action):
			#await anim.animation_finished
			#return false
		#await get_tree().physics_frame #the forbidden loop
