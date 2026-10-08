extends Node3D
@export var cajas : Array [Caja]
@export var fragmentos : Array [int]
func mezclar_cajas():
	fragmentos.shuffle()
	for i in cajas.size():
		cajas[i].fragmentos = fragmentos[i]


func _ready() -> void:
	mezclar_cajas()
