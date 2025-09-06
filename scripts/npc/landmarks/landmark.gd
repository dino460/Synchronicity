extends Node3D

class_name Landmark

@export var id : int
@export var landmark_name : String
@export var reputations = {}
@export var radius_of_influence : float
@export var area_max_influence : float

func _ready():
	add_to_group("persist")
	id = get_tree().get_root().get_node("Main/Scheduler").request_id()


func run():
	print(landmark_name, " is running")


func get_npc_want(npc : NPC, _is_at_landmark : bool, interference : float) -> float:
	var npc_reputation_here = get_npc_reputation(npc.id)

	var distance_weight = npc.personality.energy * influence_by_distance(npc.position.distance_to(self.position))
	var loyalty_weight = npc.personality.loyalty * npc_reputation_here
	var avoidance_weight = npc.personality.aggression / npc_reputation_here

	return ((distance_weight + loyalty_weight) / (time_to_arrive(npc) + avoidance_weight)) + interference


func get_npc_attraction(npc_ref : NPC, _is_current_location : bool, _special_check_var : bool) -> float:
	var npc_reputation_here = get_npc_reputation(npc_ref.id)

	var distance_weight = npc_ref.personality.energy * influence_by_distance(npc_ref.position.distance_to(self.position))
	var loyalty_weight = npc_ref.personality.loyalty * npc_reputation_here
	var avoidance_weight = npc_ref.personality.aggression / npc_reputation_here

	return ((distance_weight + loyalty_weight) / (time_to_arrive(npc_ref) + avoidance_weight))


func is_home() -> bool:
	return false

func is_job() -> bool:
	return false


func get_npc_reputation(npc_id : int) -> float:
	if not reputations.has(npc_id):
		reputations[npc_id] = 1.0
	return reputations[npc_id]

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
