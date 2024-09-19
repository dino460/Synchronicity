extends Node3D

class_name Landmark

@export var id : int
@export var landmark_name : String
@export var reputations : Array[Reputation]

func _ready():
	add_to_group("persist")
	id = get_tree().get_root().get_node("Main/Scheduler").request_id()

func get_npc_want(npc : NPC, _is_at_landmark : bool) -> float:
	var npc_reputation_here = get_npc_reputation(npc.id)
	var randomness = (npc.personality.chaos * randf_range(-1.0, 1.0))

	var distance_weight = npc.personality.energy / npc.position.distance_to(self.position)
	var loyalty_weight = npc.personality.loyalty * npc_reputation_here
	var avoidance_weight = npc.personality.aggression / npc_reputation_here

	return randomness + ((distance_weight + loyalty_weight) / (time_to_arrive(npc) + avoidance_weight))

func get_npc_reputation(npc_id : int) -> float:
	for rep in reputations:
		if rep.npc_id == npc_id:
			return rep.reputation_here

	reputations.append(Reputation.new(npc_id))
	return 1.0

func time_to_arrive(npc : NPC) -> float:
	return npc.position.distance_to(self.position) / npc.get_speed()

func save():
	var save_dict = {
		"filename" : get_scene_file_path(),
		"parent" : get_parent().get_path(),
		"pos_x" : position.x,
		"pos_y" : position.y,
		"pos_z" : position.z,
		"id" : id,
		"reputations" : reputations
	}
	return save_dict