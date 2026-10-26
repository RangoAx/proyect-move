extends Area3D

@export var damage: float = 30.0
@export var escape_presses: int = 8 
@export var slow_duration: float = 3.0

var _player_trapped: bool = false
var _press_count: int = 0

@onready var trap_hud: CanvasLayer = $TrapHUD
@onready var escape_progress: ProgressBar = %EscapeProgress
@onready var lbl_press_count: Label = %LblPressCount
@onready var key_badge: PanelContainer = %KeyBadge
@onready var jaw_left: Node3D = find_child("JawLeft", true, false) as Node3D
@onready var jaw_right: Node3D = find_child("JawRight", true, false) as Node3D

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	if trap_hud:
		trap_hud.visible = false

func _process(_delta: float) -> void:
	if not _player_trapped:
		return
		
	if Input.is_action_just_pressed("interact"):
		_press_count += 1
		_update_hud()
		_pulse_key()
		if _press_count >= escape_presses:
			_escape()

func _update_hud() -> void:
	if escape_progress:
		escape_progress.value = _press_count
	if lbl_press_count:
		lbl_press_count.text = "%d / %d" % [_press_count, escape_presses]

func _pulse_key() -> void:
	if not key_badge:
		return
	var tween = create_tween()
	tween.tween_property(key_badge, "scale", Vector2(1.25, 1.25), 0.05).set_trans(Tween.TRANS_QUAD)
	tween.tween_property(key_badge, "scale", Vector2(1.0, 1.0), 0.08).set_trans(Tween.TRANS_QUAD)

func _snap_jaws() -> void:
	if jaw_left and jaw_right:
		var tween = create_tween().set_parallel(true)
		tween.tween_property(jaw_left, "rotation:z", deg_to_rad(-10.0), 0.06).set_trans(Tween.TRANS_BOUNCE)
		tween.tween_property(jaw_right, "rotation:z", deg_to_rad(10.0), 0.06).set_trans(Tween.TRANS_BOUNCE)

func _on_body_entered(body: Node3D) -> void:
	if body == Globals.player and not _player_trapped:
		_player_trapped = true
		_press_count = 0
		_snap_jaws()
		
		if Globals.player and "movement" in Globals.player and Globals.player.movement:
			Globals.player.movement.trapped = true
		if Globals.player and Globals.player.has_method("take_damage"):
			Globals.player.take_damage(damage)
			
		if trap_hud:
			trap_hud.visible = true
			if escape_progress:
				escape_progress.max_value = escape_presses
			_update_hud()
			
	elif body is NPC and not _player_trapped:
		_snap_jaws()
		body.take_damage(damage, global_position)
		_trap_enemy(body)

func _trap_enemy(enemy: NPC) -> void:
	set_deferred("monitoring", false)
	if trap_hud:
		trap_hud.visible = false
	enemy.hitstun_timer = 4.0 
	await get_tree().create_timer(4.0).timeout
	if is_instance_valid(enemy):
		var original_speed = enemy.move_speed
		enemy.move_speed = original_speed / 2.0
		
		await get_tree().create_timer(slow_duration).timeout
		if is_instance_valid(enemy):
			enemy.move_speed = original_speed
			
	queue_free()

func _escape() -> void:
	_player_trapped = false
	if trap_hud:
		trap_hud.visible = false
	set_deferred("monitoring", false)
	
	if Globals.player and "movement" in Globals.player and Globals.player.movement:
		Globals.player.movement.trapped = false
		var original_walk = Globals.player.movement.walk_speed
		var original_run = Globals.player.movement.run_speed

		Globals.player.movement.walk_speed = 4.0
		Globals.player.movement.run_speed = 6.0

		await get_tree().create_timer(slow_duration).timeout
		
		if is_instance_valid(Globals.player) and Globals.player.movement:
			Globals.player.movement.walk_speed = original_walk
			Globals.player.movement.run_speed = original_run

	queue_free()
