extends Node

class_name Reputation

@export var npc_id : int
@export var reputation_here : float
@export var visits_here : int

func _init(new_npc_id : int) -> void:
	npc_id = new_npc_id
	reputation_here = 1.0
	visits_here = 1
