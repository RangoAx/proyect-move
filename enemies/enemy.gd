extends NPC
class_name Enemy

@export var speed = 2
@export var gravity : float = 10

@export var detection_range : float = 5.0 # Rango por proximidad del GDD
@export var attack_range : float

@export_group("Fragment Drops")
@export var amount_scarce: int = 5
@export var amount_generous: int = 15
@export var no_drop_chance: int = 20 # 20% de probabilidad de no dar nada

var player : Node3D = null
var state: String = "idle" 
var override_look: bool = false
var is_aware: bool = false # Estado de alerta

var is_attacking: bool = false
var current_damage: float = 0.0
var current_knockback: float = 0.0

@onready var life_bar = $SubViewport/EnemyLifeBar

@export var anim : AnimationPlayer
var enemy_meshes : Array[MeshInstance3D] = []

func _ready():
	life_bar.max_value = health
	life_bar.value = health
	
	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		player = players[0]
		
	took_damage.connect(_on_took_damage)
	
	# Detecta automáticamente el AnimationPlayer si no lo asignaste a mano
	if not anim:
		anim = find_child("AnimationPlayer", true, false) as AnimationPlayer
		
	# Guarda todas las mallas del modelo (útil si el nuevo modelo tiene ropa/armas separadas)
	for child in find_children("*", "MeshInstance3D"):
		enemy_meshes.append(child)

func flash_red():
	if enemy_meshes.is_empty():
		return
		
	var flash_mat = enemy_meshes[0].get_active_material(0) as StandardMaterial3D
	var texture = enemy_meshes[0].get_active_material(0).albedo_texture
	flash_mat.albedo_texture = null
	flash_mat.albedo_color = Color(1, 0, 0)
	flash_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	
	await get_tree().create_timer(0.15).timeout
	flash_mat.albedo_texture = texture
	flash_mat.albedo_color = Color(1, 1, 1)
	flash_mat.shading_mode = BaseMaterial3D.SHADING_MODE_PER_PIXEL

func _on_took_damage():
	is_aware = true
	flash_red()
	# Interrumpe cualquier combo si el enemigo recibe daño
	is_attacking = false 
	
var is_lunging: bool = false

func _physics_process(delta: float) -> void:
	if is_attacking and not is_lunging:
		velocity.x = move_toward(velocity.x, 0, delta * 15.0)
		velocity.z = move_toward(velocity.z, 0, delta * 15.0)
	# (Tu lógica de detección actual va aquí...)
	if player and not is_aware:
		var dist = global_position.distance_to(player.global_position)
		if dist <= detection_range:
			is_aware = true
		else:
			ai_enabled = false
			velocity.x = move_toward(velocity.x, 0, delta * 20.0)
			velocity.z = move_toward(velocity.z, 0, delta * 20.0)
			
	if is_aware:
		ai_enabled = true

	super._physics_process(delta)

	if player and not override_look and hitstun_timer <= 0 and is_aware and not is_attacking:
		var look_target = Vector3(player.global_position.x, global_position.y, player.global_position.z)
		if global_position.distance_to(look_target) > 0.1:
			look_at(look_target)
			rotation_degrees.y += 180

	animation_process(delta)

func animation_process(delta):
	pass

func _process(delta: float) -> void:
	life_bar.value = health
	# Oculta la barra de vida hasta que el combate empiece
	life_bar.visible = is_aware
	


const fragmento_escena = preload("res://components/fragmento.tscn")
func die():
	var roll = randi() % 100
	if roll >= no_drop_chance:
		var is_generous = (randi() % 100) > 60
		var gained = amount_generous if is_generous else amount_scarce
		for i in range(gained):
			print("fragmento creado")
			var fragmento_nuevo : RigidBody3D = fragmento_escena.instantiate()
			get_parent().add_child(fragmento_nuevo)
			fragmento_nuevo.global_position = global_position
			fragmento_nuevo.apply_central_impulse(Vector3(randf_range(-1,1),2,randf_range(-1,1)))
	super.die()
