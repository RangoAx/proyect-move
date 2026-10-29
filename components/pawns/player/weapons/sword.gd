extends Weapon
class_name SwordWeapon

@export var sword_area : Area3D
var enemies_hit = []

var base_damage : float = 20.0
var is_estocada : bool = false
var estocada_hit : bool = false

func get_damage() -> float:
	if Globals.knife_level >= 3:
		return 25.0 
	return base_damage 

@onready var slash_trail : MeshInstance3D = sword_area.get_parent().get_node_or_null("SlashTrail")

func _ready():
	sword_area.monitoring = false
	if slash_trail:
		slash_trail.is_emitting = false # Changed
	if not sword_area.body_entered.is_connected(_on_body_entered):
		sword_area.body_entered.connect(_on_body_entered)

func hitbox_open():
	if not sword_area.monitoring:
		enemies_hit.clear()
	sword_area.monitoring = true
	if slash_trail:
		slash_trail.is_emitting = true
	_check_hitbox()

func _check_hitbox() -> void:
	if not sword_area:
		return
	for body in sword_area.get_overlapping_bodies():
		_on_body_entered(body)
	if player and is_instance_valid(player):
		var space = player.get_world_3d().direct_space_state if player.get_world_3d() else null
		if space:
			var query = PhysicsShapeQueryParameters3D.new()
			var sphere = SphereShape3D.new()
			sphere.radius = 2.4
			query.shape = sphere
			var fwd = -player.movement.mesh.global_transform.basis.z.normalized() if (player.movement and player.movement.mesh) else -player.global_transform.basis.z.normalized()
			query.transform = Transform3D(Basis(), player.global_position + fwd * 1.2 + Vector3(0, 0.8, 0))
			query.collision_mask = 2 # Capa 2: Enemigos
			var hits = space.intersect_shape(query, 16)
			for hit in hits:
				if hit.collider is Node3D:
					_on_body_entered(hit.collider)

func hitbox_close():
	sword_area.monitoring = false
	if slash_trail:
		slash_trail.is_emitting = false

func attack():
	if not Globals.can_attack:
		return
		
	if is_estocada:
		return
		
	is_estocada = false
	weapon_manager.is_attacking = true
	
	# GOLPE 1
	var dir_1 = player.global_position - player.movement.mesh.global_transform.basis.z
	player.movement.apply_knockback(dir_1, 0.12)
	hitbox_open()
	
	var did_follow_1 = await play_attack_animation("Ataque1", 0.2)
	hitbox_close()
	if did_follow_1:
		# GOLPE 2
		var dir_2 = player.global_position - player.movement.mesh.global_transform.basis.z
		player.movement.apply_knockback(dir_2, 0.12)
		hitbox_open()
		
		var did_follow_2 = await play_attack_animation("Ataque2", 0.1)
		hitbox_close()
		if did_follow_2:
			# GOLPE 3
			var dir_3 = player.global_position - player.movement.mesh.global_transform.basis.z
			player.movement.apply_knockback(dir_3, 0.2)
			hitbox_open()
			await play_attack_animation("Ataque3", 0.1)
			hitbox_close()
			
	hitbox_close()
	weapon_manager.is_attacking = false
	
func aim_start():
	if not Globals.can_attack:
		return
		
	if Globals.knife_level >= 2 and not is_estocada:
		try_estocada()
	

func aim_attack():
	pass

func try_estocada():
	is_estocada = true
	estocada_hit = false
	
	weapon_manager.is_attacking = true
	
	if player.movement:
		player.movement.trapped = true
		
	if player.anim:
		player.anim.play("cargando_ataque")

	var charge_time = 0.0
	var canceled = false
	while charge_time < 1.2:
		await get_tree().physics_frame
		charge_time += get_physics_process_delta_time()
		
		if not Input.is_action_pressed("aim"):
			canceled = true
			break
			
	if canceled:
		if player.movement:
			player.movement.trapped = false
		is_estocada = false
		weapon_manager.is_attacking = false
		return
	
	if player.anim:
		player.anim.play("estocada_ataque")
		
	var push_origin = player.global_position - player.movement.mesh.global_transform.basis.z
	player.movement.apply_knockback(push_origin, 2.0) 
		
	hitbox_open()
	await get_tree().create_timer(0.33).timeout
	hitbox_close()
	
	if not estocada_hit:
		await get_tree().create_timer(1.2).timeout
		
	if player.movement:
		player.movement.trapped = false
	
	is_estocada = false
	weapon_manager.is_attacking = false
	end()

func _on_body_entered(body : Node3D):
	if body is NPC:
		if body in enemies_hit:
			return
		enemies_hit.append(body)
		
		var damage_to_deal : float = 50.0 if is_estocada else get_damage()
		# Multiplica el empuje x4 si es estocada, o déjalo en x1 si es normal
		var knockback_force : float = 4.0 if is_estocada else 1.0 
		
		body.take_damage(damage_to_deal, player.global_position, knockback_force)
		
		if is_estocada:
			estocada_hit = true

func end():
	sword_area.set_deferred("monitoring", false)
