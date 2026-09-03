extends HBoxContainer
class_name AbilityBranch

@export var ability_string : String
@export var main_icon : Texture
@export var main_explanation : String
@export var ability_1_icon : Texture 
@export var ability_1_explanation : String
@export var ability_2_icon : Texture
@export var ability_2_explanation : String

func _ready():
	$IconoPrincipal/Icono.texture = main_icon
	$IconoPrincipal.tooltip_text = main_explanation
	$Habilidad1/Icono.texture = ability_1_icon
	$Habilidad1/Icono.tooltip_text = ability_1_explanation
	$Habilidad2/Icono.texture = ability_2_icon
	$Habilidad2/Icono.tooltip_text = ability_2_explanation

func _on_button_pressed() -> void:
	Globals._process_upgrade(ability_string)
