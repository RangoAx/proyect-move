extends "res://levels/map_1/church_insides.gd"

func _ready() -> void:
	super._ready()
	print("--- TEST JEFE DE LA IGLESIA (LEÑADOR) ---")
	await get_tree().create_timer(0.2).timeout
	
	var boss = get_node_or_null("LumberjackEnemy") as Enemy
	assert(boss != null, "El jefe Leñador debe existir en la iglesia")
	assert(boss.health == 500.0, "La vida del jefe debe ser 500")
	print("1. Jefe detectado: HP=", boss.health)
	
	var player = get_node_or_null("Player") as Player
	assert(player != null, "El jugador debe existir en la iglesia")
	print("2. Jugador detectado en la iglesia: HP=", player.health)
	
	# Dañar al jefe
	boss.take_damage(50.0)
	assert(boss.health == 450.0, "El jefe debe recibir daño")
	print("3. Daño al jefe verificado: HP=", boss.health)
	
	# Simular derrota del jefe y pantalla de finalización
	boss.health = 10.0
	boss.take_damage(20.0)
	print("4. Jefe derrotado: is_dead=", boss.is_dead)
	assert(boss.is_dead == true, "El jefe debe morir al llegar a 0 de vida")
	
	await get_tree().create_timer(0.5).timeout
	var ending = get_node_or_null("EndingCanvas/EndingControl") as Control
	assert(ending != null, "La pantalla de finalización debe existir")
	assert(ending.visible == true, "La pantalla de finalización debe activarse")
	print("5. Pantalla de créditos y lore final activada correctamente")
	
	print("\n==========================================")
	print("¡TEST DEL JEFE Y FINAL DEL JUEGO: 100% OK!")
	print("==========================================")
	get_tree().quit(0)

