@icon("res://assets/textures/icons/behavior_tree/behavior_node.svg")
@abstract
extends Node
class_name BehaviorNode

enum Result {SUCCESS, FAILURE, RUNNING}

@abstract func step() -> Result
