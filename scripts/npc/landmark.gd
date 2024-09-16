extends Node3D

class_name Landmark

@export var reputations : Array[Reputation]

func get_npc_want(npc : NPC) -> float:
	var time_to_arrive = npc.position.distance_to(self.position) / npc.get_speed()
	var npc_reputation_here = get_npc_reputation(npc.id)
	var randomness = (npc.personality.chaos * randf_range(-1.0, 1.0))

	return randomness + ((npc.personality.energy + (npc.personality.loyalty * npc_reputation_here)) / (time_to_arrive + (npc.personality.aggression / npc_reputation_here)))

func get_npc_reputation(npc_id : int) -> float:
	for rep in reputations:
		if rep.npc_id == npc_id:
			return rep.reputation_here

	return 0
