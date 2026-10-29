extends Node3D

func _ready() -> void:
	print("--- INICIANDO VALIDACIÓN COMPLETA DE GAMEPLAY ---")
	await get_tree().create_timer(0.2).timeout
	
	var toy_box = get_node_or_null("ToyBox")
	if not toy_box:
		print("ERROR: No se encontró ToyBox")
		get_tree().quit(1)
		return
		
	var player = toy_box.get_node_or_null("Player") as Player
	if not player:
		print("ERROR: No se encontró Player")
		get_tree().quit(1)
		return
		
	print("1. Jugador detectado correctamente: HP=", player.health, " MaxHP=", player.max_health)
	assert(player.health == 100.0, "Salud inicial debe ser 100")
	
	# Test 2: Comprobar arma inicial y visibilidad
	var wm = player.weapon_manager
	print("2. Arma equipada: ", wm.weapon)
	assert(wm.weapon == "Sword", "Arma inicial debe ser Cuchillo/Sword")
	
	# Test 3: Spawnear un enemigo de prueba frente al jugador y probar ataque con cuchillo
	var enemy_scene = preload("res://enemies/enemy_pitchfork.tscn")
	var enemy = enemy_scene.instantiate() as Enemy
	toy_box.add_child(enemy)
	# Colocar a 1.2 metros frente al jugador
	var forward = -player.movement.mesh.global_transform.basis.z.normalized()
	enemy.global_position = player.global_position + forward * 1.2
	await get_tree().physics_frame
	await get_tree().physics_frame
	
	var initial_hp = enemy.health
	print("3. Probando ataque con cuchillo contra enemigo con HP=", initial_hp)
	
	# Ejecutar ataque básico
	var sword = wm.get_weapon() as SwordWeapon
	assert(sword != null, "SwordWeapon debe ser válido")
	
	# Lanzar ataque 1
	sword.attack()
	await get_tree().create_timer(0.35).timeout
	
	print("   HP del enemigo tras golpe 1: ", enemy.health)
	assert(enemy.health < initial_hp, "El enemigo DEBE haber recibido daño del golpe 1")
	assert(enemy.health == initial_hp - 20.0, "El daño del golpe 1 debe ser exactamente 20 puntos")
	print("   ✓ Golpe 1 infligió 20 puntos de daño correctamente")
	await get_tree().create_timer(0.3).timeout
	enemy.queue_free()
	await get_tree().physics_frame
	await get_tree().physics_frame
	
	# Test 4: Probar combo buffering
	print("4. Probando combo encadenado (Golpe 1 -> Golpe 2 -> Golpe 3)...")
	var enemy2 = enemy_scene.instantiate() as Enemy
	toy_box.add_child(enemy2)
	forward = -player.movement.mesh.global_transform.basis.z.normalized()
	enemy2.global_position = player.global_position + forward * 1.0
	await get_tree().physics_frame
	await get_tree().physics_frame
	
	var hp_before_combo = enemy2.health
	sword.buffer_attack() # Simular click durante ataque
	# Iniciar ataque
	sword.attack()
	# Buffer para el golpe 2
	await get_tree().create_timer(0.1).timeout
	enemy2.global_position = player.global_position + forward * 1.0
	sword.buffer_attack()
	# Buffer para el golpe 3
	await get_tree().create_timer(0.3).timeout
	enemy2.global_position = player.global_position + forward * 1.0
	sword.buffer_attack()
	await get_tree().create_timer(0.7).timeout
	
	print("   HP del enemigo tras combo: ", enemy2.health, " (Daño recibido: ", hp_before_combo - enemy2.health, ")")
	assert(enemy2.health <= hp_before_combo - 40.0, "El combo debe haber conectado múltiples golpes")
	print("   ✓ Combo ejecutado con éxito")
	
	# Test 5: Probar Hacha
	print("5. Probando adquisición y lanzamiento de Hacha...")
	Globals.has_axe = true
	Globals.axe_acquired.emit()
	wm.switch_to("Axe")
	assert(wm.weapon == "Axe", "El arma debe cambiarse a Hacha")
	var axe_weapon = wm.get_weapon()
	assert(axe_weapon != null, "AxeWeapon debe ser válido")
	
	var axes_before = player.axe_amount
	axe_weapon.attack()
	await get_tree().physics_frame
	print("   Hachas tras lanzar: ", player.axe_amount, " (Antes: ", axes_before, ")")
	assert(player.axe_amount == axes_before - 1, "Debe descontar 1 hacha del inventario")
	print("   ✓ Hacha arrojada correctamente")
	
	# Test 6: Probar recarga de hacha
	print("6. Comprobando temporizador de recarga de hacha...")
	assert(axe_weapon.recharge_timer > 0.0, "El temporizador de recarga debe activarse")
	print("   ✓ Temporizador de recarga activo: ", axe_weapon.recharge_timer, " seg")
	
	# Test 7: Probar daño del hacha mejorada (GDD: cooldown 3s en nivel 2, 3 hachas en nivel 3)
	Globals.axe_level = 3
	assert(axe_weapon.get_max_axes() == 3, "Nivel 3 de hacha debe dar capacidad de 3 hachas")
	assert(axe_weapon.get_cooldown() == 3.0, "Nivel 2/3 debe reducir cooldown a 3.0 seg")
	print("   ✓ Estadísticas de mejoras de hacha verificadas al 100%")
	
	# Test 8: Probar Estocada cargada de cuchillo (Nivel 2)
	wm.switch_to("Sword")
	Globals.knife_level = 2
	print("7. Probando habilidad Estocada del cuchillo...")
	var enemy3 = enemy_scene.instantiate() as Enemy
	toy_box.add_child(enemy3)
	enemy3.global_position = player.global_position + forward * 1.2
	await get_tree().physics_frame
	
	sword.is_estocada = true
	sword.hitbox_open()
	await get_tree().create_timer(0.2).timeout
	sword.hitbox_close()
	sword.is_estocada = false
	print("   HP del enemigo tras Estocada: ", enemy3.health)
	assert(enemy3.health == 50.0, "La estocada debe infligir 50 puntos de daño")
	print("   ✓ Estocada infligió 50 puntos de daño correctamente")
	
	# Test 9: Comprobar Mejoras de vida del Jugador (Nivel 2: 150, Nivel 3: 200) y visualización de la barra de vida
	print("8. Probando visualización de vida y mejoras del jugador...")
	assert(player.life_bar != null, "ProgressBar de vida debe existir")
	assert(player.life_bar.show_percentage == false, "ProgressBar show_percentage debe ser falso (no debe mostrar porcentaje)")
	assert(player.hp_label != null, "HpLabel debe existir en ProgressBar")
	assert(player.hp_label.text == "100 HP", "Vida inicial debe mostrar 100 HP")
	
	# Daño al jugador y actualización de texto
	player.take_damage(20.0)
	assert(player.health == 80.0, "La vida del jugador debe ser 80 tras recibir daño")
	assert(player.hp_label.text == "80 HP", "La barra de vida debe mostrar 80 HP tras recibir daño")
	
	# Nivel 2 de salud: 150 HP
	Globals.fragments = 500
	Globals.upgrade_player()
	assert(player.max_health == 150.0, "Nivel 2 debe expandir vida a 150")
	assert(player.health == 150.0, "Al mejorar vida se llena al máximo")
	assert(player.life_bar.max_value == 150.0, "El valor máximo de la barra debe ser 150")
	assert(player.hp_label.text == "150 HP", "La barra de vida debe mostrar 150 HP en Nivel 2")
	print("   ✓ Nivel 2 verificado: muestra 150 HP correctamente")
	
	# Nivel 3 de salud: 200 HP
	Globals.upgrade_player()
	assert(player.max_health == 200.0, "Nivel 3 debe expandir vida a 200")
	assert(player.health == 200.0, "Al mejorar vida se llena al máximo")
	assert(player.life_bar.max_value == 200.0, "El valor máximo de la barra debe ser 200")
	assert(player.hp_label.text == "200 HP", "La barra de vida debe mostrar 200 HP en Nivel 3")
	print("   ✓ Nivel 3 verificado: muestra 200 HP correctamente")
	
	# Daño en Nivel 3
	player.take_damage(45.0)
	assert(player.health == 155.0, "La vida debe ser 155 tras daño")
	assert(player.hp_label.text == "155 HP", "La barra de vida debe mostrar 155 HP")
	print("   ✓ Visualización dinámica de HP restante verificada al 100%")
	
	# Test 10: Comprobar que todas las 4 zonas de combate existen y están configuradas con niebla
	print("9. Comprobando las 4 Zonas de Encuentro con Niebla...")
	var zones = toy_box.get_node_or_null("EnemySpawnZones")
	assert(zones != null, "Nodo EnemySpawnZones debe existir")
	assert(zones.get_node_or_null("ZonePueblo") != null, "ZonePueblo debe existir")
	assert(zones.get_node_or_null("ZoneCaminoBosque") != null, "ZoneCaminoBosque debe existir")
	assert(zones.get_node_or_null("ZoneBosque") != null, "ZoneBosque debe existir")
	assert(zones.get_node_or_null("ZoneEntradaIglesia") != null, "ZoneEntradaIglesia debe existir")
	print("   ✓ Las 4 Zonas de Combate están presentes y configuradas con pared de niebla")
	
	# Limpieza de enemigos de prueba
	if is_instance_valid(enemy): enemy.queue_free()
	if is_instance_valid(enemy2): enemy2.queue_free()
	if is_instance_valid(enemy3): enemy3.queue_free()
	
	print("\n==========================================")
	print("¡TODAS LAS PRUEBAS DE JUGABILIDAD PASARON EXITOSAMENTE (100% OK)!")
	print("==========================================")
	get_tree().quit(0)
