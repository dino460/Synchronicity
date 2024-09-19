extends Node

class_name Reputation

@export var npc_id : int
@export var reputation_here : float

func _init(new_npc_id : int) -> void:
	npc_id = new_npc_id
	reputation_here = 1
