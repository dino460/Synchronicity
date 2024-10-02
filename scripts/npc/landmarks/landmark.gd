extends Node3D

class_name Landmark

@export var id : int
@export var landmark_name : String
@export var reputations : Array[Reputation]
@export var radius_of_influence : float
@export var area_max_influence : float

func _ready():
	add_to_group("persist")
	id = get_tree().get_root().get_node("Main/Scheduler").request_id()

func get_npc_want(npc : NPC, _is_at_landmark : bool, interference : float) -> float:
	var npc_reputation_here = get_npc_reputation(npc.id)

	var distance_weight = npc.personality.energy * influence_by_distance(npc.position.distance_to(self.position))
	var loyalty_weight = npc.personality.loyalty * npc_reputation_here
	var avoidance_weight = npc.personality.aggression / npc_reputation_here

	return ((distance_weight + loyalty_weight) / (time_to_arrive(npc) + avoidance_weight)) + interference

func get_npc_reputation(npc_id : int) -> float:
	for rep in reputations:
		if rep.npc_id == npc_id:
			return rep.reputation_here

	reputations.append(Reputation.new(npc_id))
	return 1.0

func time_to_arrive(npc : NPC) -> float:
	return npc.position.distance_to(self.position) / npc.get_speed()

func influence_by_distance(distance : float) -> float:
	if distance <= radius_of_influence:
		return area_max_influence
	return area_max_influence / exp(distance - radius_of_influence)

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
