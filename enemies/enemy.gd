extends NPC
class_name Enemy

# ─── Stats ────────────────────────────────────────────────────────────────────
@export var speed: float = 2.0
@export var gravity: float = 10.0
@export var detection_range: float = 5.0
@export var attack_range: float

# ─── Fragment Drops ───────────────────────────────────────────────────────────
@export_group("Fragment Drops")
@export var amount_scarce: int = 5
@export var amount_generous: int = 15
@export var no_drop_chance: int = 20  # % chance of dropping nothing

# ─── Runtime State ────────────────────────────────────────────────────────────
var player: Node3D = null
var state: String = "idle"
var override_look: bool = false
var is_aware: bool = false
var is_attacking: bool = false
var is_lunging: bool = false
var current_damage: float = 0.0
var current_knockback: float = 0.0

# ─── Nodes ────────────────────────────────────────────────────────────────────
@onready var life_bar = $SubViewport/EnemyLifeBar
@onready var hp_label: Label = null
@export var anim: AnimationPlayer

# Per-instance material copies for the hit-flash (avoids mutating the shared resource)
var _mesh_materials: Array[StandardMaterial3D] = []
var _original_albedos: Array[Color] = []
var _original_emissions: Array[Color] = []
var _original_emission_enabled: Array[bool] = []
var _is_flashing: bool = false

# ─────────────────────────────────────────────────────────────────────────────
func _ready() -> void:
	_find_player()
	_setup_life_bar()
	_setup_anim()
	_cache_instance_materials()
	took_damage.connect(_on_took_damage)


func _find_player() -> void:
	var players := get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		player = players[0]


func _setup_life_bar() -> void:
	if not hp_label and life_bar and life_bar.has_node("HpLabel"):
		hp_label = life_bar.get_node("HpLabel") as Label
	if life_bar:
		life_bar.max_value = health
		life_bar.value = health
	_update_hp_label()


func _update_hp_label() -> void:
	if not hp_label and life_bar and life_bar.has_node("HpLabel"):
		hp_label = life_bar.get_node("HpLabel") as Label
	if hp_label:
		hp_label.text = str(maxi(0, int(ceil(health))))


func _setup_anim() -> void:
	if not anim:
		anim = find_child("AnimationPlayer", true, false) as AnimationPlayer


func _cache_instance_materials() -> void:
	_mesh_materials.clear()
	_original_albedos.clear()
	_original_emissions.clear()
	_original_emission_enabled.clear()

	# Duplicate every surface material so we never touch the shared resource.
	for mesh in find_children("*", "MeshInstance3D") as Array[MeshInstance3D]:
		for surface in range(mesh.get_surface_override_material_count()):
			var original := mesh.get_active_material(surface) as StandardMaterial3D
			if original:
				var copy := original.duplicate() as StandardMaterial3D
				mesh.set_surface_override_material(surface, copy)
				_mesh_materials.append(copy)
				_original_albedos.append(copy.albedo_color)
				_original_emissions.append(copy.emission)
				_original_emission_enabled.append(copy.emission_enabled)


# ─── Hit Flash ────────────────────────────────────────────────────────────────
func flash_red() -> void:
	# Guard: don't restart the flash while it is already running.
	if _is_flashing or _mesh_materials.is_empty():
		return

	_is_flashing = true

	for mat in _mesh_materials:
		if is_instance_valid(mat):
			mat.albedo_color = Color(1.0, 0.0, 0.0)
			mat.emission_enabled = true
			mat.emission = Color(0.6, 0.0, 0.0)

	await get_tree().create_timer(0.15).timeout
	if not is_instance_valid(self) or not is_inside_tree():
		return

	for i in range(_mesh_materials.size()):
		var mat := _mesh_materials[i]
		if is_instance_valid(mat):
			mat.albedo_color = _original_albedos[i]
			mat.emission = _original_emissions[i]
			mat.emission_enabled = _original_emission_enabled[i]

	_is_flashing = false


# ─── Damage Callback ──────────────────────────────────────────────────────────
func _on_took_damage() -> void:
	is_aware = true
	is_attacking = false

	flash_red()
	_disable_all_hitboxes(self)

	if anim:
		anim.stop()


# Recursively disables every Area3D named "*Hitbox*" in the subtree.
func _disable_all_hitboxes(node: Node) -> void:
	for child in node.get_children():
		if child is Area3D and "Hitbox" in child.name:
			child.set_deferred("monitoring", false)
		_disable_all_hitboxes(child)


# ─── Physics ──────────────────────────────────────────────────────────────────
func _physics_process(delta: float) -> void:
	_update_awareness(delta)
	super._physics_process(delta)
	_update_look_at()
	animation_process(delta)


func _update_awareness(delta: float) -> void:
	if not player:
		return

	if not is_aware:
		var dist := global_position.distance_to(player.global_position)
		if dist <= detection_range:
			is_aware = true
		else:
			ai_enabled = false
			velocity.x = move_toward(velocity.x, 0.0, delta * 20.0)
			velocity.z = move_toward(velocity.z, 0.0, delta * 20.0)

	if is_aware:
		ai_enabled = true

	# Damp horizontal velocity while attacking (unless lunging)
	if is_attacking and not is_lunging:
		velocity.x = move_toward(velocity.x, 0.0, delta * 15.0)
		velocity.z = move_toward(velocity.z, 0.0, delta * 15.0)


func _update_look_at() -> void:
	if not player or override_look or hitstun_timer > 0 or not is_aware or is_attacking:
		return
	var look_target := Vector3(player.global_position.x, global_position.y, player.global_position.z)
	if global_position.distance_to(look_target) > 0.1:
		look_at(look_target)
		rotation_degrees.y += 180


# ─── Process ──────────────────────────────────────────────────────────────────
func _process(_delta: float) -> void:
	if life_bar:
		life_bar.value = health
		life_bar.visible = is_aware
	_update_hp_label()


# ─── Animation ────────────────────────────────────────────────────────────────
## Override in subclasses to drive idle/walk/attack animations.
func animation_process(_delta: float) -> void:
	pass


# ─── Death ────────────────────────────────────────────────────────────────────
const fragmento_escena = preload("res://components/fragmento.tscn")

func die() -> void:
	var roll := randi() % 100
	if roll >= no_drop_chance:
		var is_generous: bool = (randi() % 100) > 60
		var count: int = amount_generous if is_generous else amount_scarce
		for i in range(count):
			var frag: RigidBody3D = fragmento_escena.instantiate()
			get_parent().add_child(frag)
			frag.global_position = global_position
			frag.apply_central_impulse(Vector3(randf_range(-1.0, 1.0), 2.0, randf_range(-1.0, 1.0)))
	super.die()
