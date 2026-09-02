extends CanvasLayer

@onready var health_vignette = $HealthVignette
@onready var death_screen = $DeathScreen
@onready var total_fragments_label = $FragmentDisplay/TotalFragments
@onready var fragment_notify_label = $FragmentDisplay/FragmentNotification
@onready var weapon_notify_panel = $WeaponNotification
@onready var weapon_name_label = $WeaponNotification/WeaponName
@onready var axe_reload_bar = $Crosshair/AxeReloadProgress
@onready var axe_ammo_label = $Crosshair/AxeAmmoLabel

var player: CharacterBody3D = null
var notify_tween: Tween
var weapon_tween: Tween

func _ready():
	Globals.fragments_updated.connect(_on_fragments_updated)
	Globals.weapon_swapped.connect(_on_weapon_swapped)
	
	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		player = players[0]
	
	fragment_notify_label.modulate.a = 0.0
	weapon_notify_panel.modulate.a = 0.0
	death_screen.visible = false

func _process(_delta):
	_update_health_vignette()
	_update_axe_hud()

func _update_health_vignette():
	if not player:
		return
	
	# Si muere, activa la pantalla roja de muerte
	if player.health <= 0:
		death_screen.visible = true
		health_vignette.color.a = 0.0
		return
	
	# Calcula la intensidad del rojo según la salud faltante
	var max_hp = 100.0
	if "max_health" in player:
		max_hp = player.max_health
	var missing_health_ratio = clamp(1.0 - (player.health / max_hp), 0.0, 1.0)
	
	# La pantalla se intensifica al estar cerca de morir
	health_vignette.color.a = missing_health_ratio * 0.75

func _update_axe_hud():
	if not player or not ("axe_amount" in player):
		return
	
	var weapon_node = player.get_node_or_null("WeaponManager/Axe")
	if not weapon_node:
		axe_reload_bar.visible = false
		axe_ammo_label.visible = false
		return
	
	# Muestra el indicador circular solo si el hacha está en recarga
	var max_axes = weapon_node.get_max_axes() if weapon_node.has_method("get_max_axes") else 1
	axe_ammo_label.text = str(player.axe_amount) + "/" + str(max_axes)
	
	if weapon_node.recharge_timer > 0.0:
		axe_reload_bar.visible = true
		var cd = weapon_node.get_cooldown()
		axe_reload_bar.value = ((cd - weapon_node.recharge_timer) / cd) * 100.0
	else:
		axe_reload_bar.visible = false

# Notificación de fragmentos al medio-derecha por 2 segundos
func _on_fragments_updated(total: int, added: int):
	total_fragments_label.text = "Fragmentos: " + str(total)
	fragment_notify_label.text = "+" + str(added)
	
	if notify_tween and notify_tween.is_valid():
		notify_tween.kill()
	
	notify_tween = create_tween()
	fragment_notify_label.modulate.a = 1.0
	notify_tween.tween_interval(2.0)
	notify_tween.tween_property(fragment_notify_label, "modulate:a", 0.0, 0.4)

# Notificación de cambio de arma abajo a la izquierda por 2 segundos
func _on_weapon_swapped(w_name: String):
	weapon_name_label.text = w_name
	
	if weapon_tween and weapon_tween.is_valid():
		weapon_tween.kill()
	
	weapon_tween = create_tween()
	weapon_notify_panel.modulate.a = 1.0
	weapon_tween.tween_interval(2.0)
	weapon_tween.tween_property(weapon_notify_panel, "modulate:a", 0.0, 0.3)
