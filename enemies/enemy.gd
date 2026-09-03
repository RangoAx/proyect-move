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

@onready var life_bar = $SubViewport/EnemyLifeBar

func _ready():
	life_bar.max_value = health
	life_bar.value = health
	
	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		player = players[0]
		
	# Si recibe un golpe directo (ej. un hachazo), se alerta al instante
	took_damage.connect(_on_took_damage)

func _on_took_damage():
	is_aware = true

func _physics_process(delta: float) -> void:
	# Lógica del Sistema de Detección
	if player and not is_aware:
		var dist = global_position.distance_to(player.global_position)
		if dist <= detection_range:
			is_aware = true
		else:
			# Si no te detectó, apaga su árbol heredado y se queda quieto
			ai_enabled = false
			velocity.x = move_toward(velocity.x, 0, delta * 20.0)
			velocity.z = move_toward(velocity.z, 0, delta * 20.0)
			
	if is_aware:
		ai_enabled = true

	# Ejecuta las físicas y el árbol de npc.gd
	super._physics_process(delta)

	# Solo rota para mirar al jugador si ya lo detectó
	if player and not override_look and hitstun_timer <= 0 and is_aware:
		var look_target = Vector3(player.global_position.x, global_position.y, player.global_position.z)
		if global_position.distance_to(look_target) > 0.1:
			look_at(look_target)
			rotation_degrees.y += 180

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
