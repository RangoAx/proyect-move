extends Control

@onready var lbl_fragments: Label = %LblFragments
@onready var lbl_desc_title: Label = %LblDescTitle
@onready var lbl_desc_text: Label = %LblDescText
@onready var lbl_desc_cost: Label = %LblDescCost
@onready var lbl_feedback: Label = %LblFeedback
@onready var rama_container: VBoxContainer = %RamaContainer
@onready var btn_back: Button = %BtnBack

const DEFAULT_TITLE = "SELECCIONA O PASA EL CURSOR SOBRE UNA MEJORA"
const DEFAULT_TEXT = "Pasa el ratón sobre cualquier icono de habilidad para conocer su efecto y costo. Haz clic para desbloquearla usando tus fragmentos."

func _ready() -> void:
	visibility_changed.connect(_on_visibility_changed)
	if has_node("/root/Globals"):
		Globals.fragments_updated.connect(_on_fragments_updated)
		Globals.upgrade_purchased.connect(_on_upgrade_purchased)

	for child in rama_container.get_children():
		if child is AbilityBranch:
			child.upgrade_hovered.connect(_on_branch_upgrade_hovered)
			child.upgrade_hover_ended.connect(_on_branch_upgrade_hover_ended)
			child.upgrade_feedback.connect(_on_branch_upgrade_feedback)

	if btn_back:
		btn_back.pressed.connect(func(): visible = false)

	_reset_description()
	update_all()

func _unhandled_input(event: InputEvent) -> void:
	if visible and event.is_action_pressed("ui_cancel"):
		visible = false
		get_viewport().set_input_as_handled()

func _on_visibility_changed() -> void:
	if visible:
		_reset_description()
		update_all()

func update_all() -> void:
	if lbl_fragments and has_node("/root/Globals"):
		lbl_fragments.text = "Fragmentos disponibles: %d" % Globals.fragments
	for child in rama_container.get_children():
		if child is AbilityBranch:
			child.update_visuals()

func _on_fragments_updated(_total: int, _added: int) -> void:
	update_all()

func _on_upgrade_purchased(_stat: String, _level: int) -> void:
	update_all()

func _reset_description() -> void:
	if lbl_desc_title:
		lbl_desc_title.text = DEFAULT_TITLE
	if lbl_desc_text:
		lbl_desc_text.text = DEFAULT_TEXT
	if lbl_desc_cost:
		lbl_desc_cost.text = ""
	if lbl_feedback:
		lbl_feedback.text = ""

func _on_branch_upgrade_hovered(title: String, description: String, cost: int, is_unlocked: bool) -> void:
	if lbl_desc_title:
		lbl_desc_title.text = title.to_upper()
	if lbl_desc_text:
		lbl_desc_text.text = description
	if lbl_desc_cost:
		if cost == 0:
			lbl_desc_cost.text = ""
		elif is_unlocked:
			lbl_desc_cost.text = "[ DESBLOQUEADO ]"
			lbl_desc_cost.modulate = Color(0.3, 1.0, 0.4)
		else:
			lbl_desc_cost.text = "Coste: %d Fragmentos" % cost
			lbl_desc_cost.modulate = Color(1.0, 0.9, 0.3)

func _on_branch_upgrade_hover_ended() -> void:
	pass

func _on_branch_upgrade_feedback(message: String, is_error: bool) -> void:
	if lbl_feedback:
		lbl_feedback.text = message
		lbl_feedback.modulate = Color(1.0, 0.35, 0.35) if is_error else Color(0.35, 1.0, 0.45)
