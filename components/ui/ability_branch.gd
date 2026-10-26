extends PanelContainer
class_name AbilityBranch

signal upgrade_hovered(title: String, description: String, cost: int, is_unlocked: bool)
signal upgrade_hover_ended()
signal upgrade_feedback(message: String, is_error: bool)

@export var ability_string : String
@export var main_icon : Texture
@export_multiline var main_explanation : String
@export var ability_1_icon : Texture 
@export_multiline var ability_1_explanation : String
@export var ability_2_icon : Texture
@export_multiline var ability_2_explanation : String

@onready var icono_principal: TextureRect = find_child("IconoPrincipal", true, false) as TextureRect
@onready var icono_main: TextureRect = icono_principal.get_node_or_null("Icono") if icono_principal else null
@onready var lbl_base: Label = find_child("LblBase", true, false) as Label
@onready var lbl_category: Label = find_child("LblCategory", true, false) as Label
@onready var lbl_level: Label = find_child("LblLevel", true, false) as Label
@onready var level_progress: ProgressBar = find_child("LevelProgress", true, false) as ProgressBar

@onready var btn_habilidad_1: Button = find_child("Habilidad1", true, false) as Button
@onready var icono_hab_1: TextureRect = btn_habilidad_1.get_node_or_null("Icono") if btn_habilidad_1 else null
@onready var lbl_hab_1: Label = find_child("LblHab1", true, false) as Label

@onready var btn_habilidad_2: Button = find_child("Habilidad2", true, false) as Button
@onready var icono_hab_2: TextureRect = btn_habilidad_2.get_node_or_null("Icono") if btn_habilidad_2 else null
@onready var lbl_hab_2: Label = find_child("LblHab2", true, false) as Label

@onready var separador_1: TextureRect = find_child("Separador1", true, false) as TextureRect
@onready var separador_2: TextureRect = find_child("Separador2", true, false) as TextureRect

func _ready() -> void:
	if main_icon and icono_main:
		icono_main.texture = main_icon
	if ability_1_icon and icono_hab_1:
		icono_hab_1.texture = ability_1_icon
	if ability_2_icon and icono_hab_2:
		icono_hab_2.texture = ability_2_icon

	# Tooltips nativos y eventos hover
	if icono_principal:
		icono_principal.tooltip_text = main_explanation
		icono_principal.mouse_entered.connect(_on_main_hover)
		icono_principal.mouse_exited.connect(_on_hover_exited)

	if btn_habilidad_1:
		btn_habilidad_1.tooltip_text = ability_1_explanation
		btn_habilidad_1.mouse_entered.connect(_on_habilidad_1_hover)
		btn_habilidad_1.mouse_exited.connect(_on_hover_exited)
		if not btn_habilidad_1.pressed.is_connected(_on_habilidad_1_pressed):
			btn_habilidad_1.pressed.connect(_on_habilidad_1_pressed)

	if btn_habilidad_2:
		btn_habilidad_2.tooltip_text = ability_2_explanation
		btn_habilidad_2.mouse_entered.connect(_on_habilidad_2_hover)
		btn_habilidad_2.mouse_exited.connect(_on_hover_exited)
		if not btn_habilidad_2.pressed.is_connected(_on_habilidad_2_pressed):
			btn_habilidad_2.pressed.connect(_on_habilidad_2_pressed)

	update_visuals()

func update_visuals() -> void:
	var cur_level: int = 1
	if ability_string != "" and has_node("/root/Globals"):
		cur_level = Globals.get(ability_string)

	var category_name: String = main_explanation.split(":")[0].strip_edges()
	if category_name == "":
		category_name = ability_string.capitalize().replace("_level", "")

	# Bloqueo especial para el Hacha hasta conseguirla
	var is_axe_locked: bool = false
	if ability_string == "axe_level":
		if has_node("/root/Globals"):
			is_axe_locked = not Globals.has_axe
		else:
			is_axe_locked = false

	if is_axe_locked:
		if lbl_category:
			lbl_category.text = "HACHA [BLOQUEADA]"
			lbl_category.modulate = Color(0.7, 0.7, 0.7)
		if lbl_level:
			lbl_level.text = "Encuentra el arma primero"
			lbl_level.modulate = Color(0.95, 0.35, 0.35)
		if level_progress:
			level_progress.value = 0
		if icono_principal:
			icono_principal.modulate = Color(0.35, 0.35, 0.35)
		if lbl_base:
			lbl_base.text = "Bloqueada"
			lbl_base.modulate = Color(0.45, 0.45, 0.45)
		if btn_habilidad_1:
			btn_habilidad_1.disabled = true
			btn_habilidad_1.modulate = Color(0.25, 0.25, 0.25)
			if lbl_hab_1:
				lbl_hab_1.text = "BLOQUEADO"
				lbl_hab_1.modulate = Color(0.4, 0.4, 0.4)
		if btn_habilidad_2:
			btn_habilidad_2.disabled = true
			btn_habilidad_2.modulate = Color(0.25, 0.25, 0.25)
			if lbl_hab_2:
				lbl_hab_2.text = "BLOQUEADO"
				lbl_hab_2.modulate = Color(0.4, 0.4, 0.4)
		if separador_1:
			separador_1.modulate = Color(0.2, 0.2, 0.2, 0.3)
		if separador_2:
			separador_2.modulate = Color(0.2, 0.2, 0.2, 0.3)
		return

	# Desbloqueado normal
	if btn_habilidad_1:
		btn_habilidad_1.disabled = false
	if btn_habilidad_2:
		btn_habilidad_2.disabled = false
	if icono_principal:
		icono_principal.modulate = Color(1.0, 1.0, 1.0)
	if lbl_base:
		lbl_base.text = "Nv. 1 (Base)"
		lbl_base.modulate = Color(0.35, 1.0, 0.45)

	if lbl_category:
		lbl_category.text = category_name.to_upper()
		lbl_category.modulate = Color(1.0, 0.95, 0.95)
	if lbl_level:
		if cur_level >= 3:
			lbl_level.text = "Nivel 3/3 (MÁX)"
			lbl_level.modulate = Color(0.35, 1.0, 0.45)
		else:
			lbl_level.text = "Nivel %d/3" % cur_level
			lbl_level.modulate = Color(1.0, 0.85, 0.4)
			
	if level_progress:
		level_progress.value = cur_level

	var cost_2 = Globals.cost_level_2 if has_node("/root/Globals") else 75
	var cost_3 = Globals.cost_level_3 if has_node("/root/Globals") else 150
	var cur_fragments = Globals.fragments if has_node("/root/Globals") else 0

	# Línea 1 (Conecta Base a Nivel 2)
	if separador_1:
		separador_1.modulate = Color(0.35, 1.0, 0.45, 0.9) if cur_level >= 2 else Color(0.5, 0.5, 0.5, 0.4)

	# Línea 2 (Conecta Nivel 2 a Nivel 3)
	if separador_2:
		separador_2.modulate = Color(0.35, 1.0, 0.45, 0.9) if cur_level >= 3 else Color(0.5, 0.5, 0.5, 0.4)

	# Visuales Nivel 2
	if btn_habilidad_1:
		if cur_level >= 2:
			if lbl_hab_1:
				lbl_hab_1.text = "ADQUIRIDO"
				lbl_hab_1.modulate = Color(0.35, 1.0, 0.45)
			btn_habilidad_1.modulate = Color(0.4, 1.0, 0.4)
		else:
			if lbl_hab_1:
				lbl_hab_1.text = "Nv. 2 (%d F)" % cost_2
				lbl_hab_1.modulate = Color(1.0, 0.85, 0.3) if cur_fragments >= cost_2 else Color(0.6, 0.6, 0.6)
			btn_habilidad_1.modulate = Color(1.0, 1.0, 1.0) if cur_fragments >= cost_2 else Color(0.65, 0.65, 0.65)

	# Visuales Nivel 3
	if btn_habilidad_2:
		if cur_level >= 3:
			if lbl_hab_2:
				lbl_hab_2.text = "ADQUIRIDO"
				lbl_hab_2.modulate = Color(0.35, 1.0, 0.45)
			btn_habilidad_2.modulate = Color(0.4, 1.0, 0.4)
		elif cur_level == 2:
			if lbl_hab_2:
				lbl_hab_2.text = "Nv. 3 (%d F)" % cost_3
				lbl_hab_2.modulate = Color(1.0, 0.85, 0.3) if cur_fragments >= cost_3 else Color(0.6, 0.6, 0.6)
			btn_habilidad_2.modulate = Color(1.0, 1.0, 1.0) if cur_fragments >= cost_3 else Color(0.65, 0.65, 0.65)
		else:
			if lbl_hab_2:
				lbl_hab_2.text = "BLOQUEADO"
				lbl_hab_2.modulate = Color(0.45, 0.45, 0.45)
			btn_habilidad_2.modulate = Color(0.35, 0.35, 0.35)

func _on_main_hover() -> void:
	if ability_string == "axe_level" and has_node("/root/Globals") and not Globals.has_axe:
		upgrade_hovered.emit("HACHA ARROJADIZA [BLOQUEADA]", "Arma a distancia bloqueada. Debes explorar el bosque y recoger el hacha antes de poder mejorarla.", 0, false)
		return
	upgrade_hovered.emit(main_explanation.split(":")[0], main_explanation, 0, true)

func _on_habilidad_1_hover() -> void:
	if ability_string == "axe_level" and has_node("/root/Globals") and not Globals.has_axe:
		upgrade_hovered.emit("HACHA ARROJADIZA [BLOQUEADA]", "Debes encontrar y recoger el hacha en el bosque antes de poder desbloquear sus mejoras.", 0, false)
		return
	var cur_level: int = Globals.get(ability_string) if has_node("/root/Globals") else 1
	var cost = Globals.cost_level_2 if has_node("/root/Globals") else 75
	upgrade_hovered.emit("MEJORA DE NIVEL 2", ability_1_explanation, cost, cur_level >= 2)

func _on_habilidad_2_hover() -> void:
	if ability_string == "axe_level" and has_node("/root/Globals") and not Globals.has_axe:
		upgrade_hovered.emit("HACHA ARROJADIZA [BLOQUEADA]", "Debes encontrar y recoger el hacha en el bosque antes de poder desbloquear sus mejoras.", 0, false)
		return
	var cur_level: int = Globals.get(ability_string) if has_node("/root/Globals") else 1
	var cost = Globals.cost_level_3 if has_node("/root/Globals") else 150
	upgrade_hovered.emit("MEJORA DE NIVEL 3", ability_2_explanation, cost, cur_level >= 3)

func _on_hover_exited() -> void:
	upgrade_hover_ended.emit()

func _on_habilidad_1_pressed() -> void:
	if not has_node("/root/Globals"):
		return
	if ability_string == "axe_level" and not Globals.has_axe:
		upgrade_feedback.emit("¡Debes encontrar el Hacha en el bosque antes de poder mejorarla!", true)
		return
	var cur_level: int = Globals.get(ability_string)
	if cur_level >= 2:
		upgrade_feedback.emit("Esta mejora ya está desbloqueada.", false)
		return
	if Globals.fragments < Globals.cost_level_2:
		upgrade_feedback.emit("Fragmentos insuficientes (requieres %d, tienes %d)." % [Globals.cost_level_2, Globals.fragments], true)
		return
	if Globals._process_upgrade(ability_string):
		upgrade_feedback.emit("¡Mejora de Nivel 2 adquirida con éxito!", false)
		update_visuals()

func _on_habilidad_2_pressed() -> void:
	if not has_node("/root/Globals"):
		return
	if ability_string == "axe_level" and not Globals.has_axe:
		upgrade_feedback.emit("¡Debes encontrar el Hacha en el bosque antes de poder mejorarla!", true)
		return
	var cur_level: int = Globals.get(ability_string)
	if cur_level >= 3:
		upgrade_feedback.emit("Esta mejora ya está al nivel máximo.", false)
		return
	if cur_level < 2:
		upgrade_feedback.emit("Debes desbloquear la mejora de Nivel 2 primero.", true)
		return
	if Globals.fragments < Globals.cost_level_3:
		upgrade_feedback.emit("Fragmentos insuficientes (requieres %d, tienes %d)." % [Globals.cost_level_3, Globals.fragments], true)
		return
	if Globals._process_upgrade(ability_string):
		upgrade_feedback.emit("¡Mejora de Nivel 3 adquirida con éxito!", false)
		update_visuals()

