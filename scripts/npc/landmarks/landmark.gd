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
	# print(landmark_name, " is running")
	pass


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


func get_attraction(distance : float, _npc_ref : NPC) -> float:
	if distance > 250:
		return 0.0
	return distance_lut[int(distance)]

var distance_lut : Array[float] = [
	10.0, 8.34, 7.14, 6.24, 5.56, 5.0, 4.54,
	4.16, 3.84, 3.58, 3.34, 3.12, 2.94, 2.78,
	2.64, 2.5, 2.38, 2.28, 2.18, 2.08, 2.0,
	1.92, 1.86, 1.78, 1.72, 1.66, 1.62, 1.56,
	1.52, 1.48, 1.42, 1.38, 1.36, 1.32, 1.28,
	1.24, 1.22, 1.2, 1.16, 1.14, 1.12, 1.08,
	1.06, 1.04, 1.02, 1.0, 0.98, 0.96, 0.94,
	0.92, 0.9, 0.9, 0.88, 0.86, 0.84, 0.84,
	0.82, 0.8, 0.8, 0.78, 0.76, 0.76, 0.74,
	0.74, 0.72, 0.72, 0.7, 0.7, 0.68, 0.68,
	0.66, 0.66, 0.64, 0.64, 0.64, 0.62, 0.62,
	0.6, 0.6, 0.6, 0.58, 0.58, 0.58, 0.56,
	0.56, 0.56, 0.54, 0.54, 0.54, 0.54, 0.52,
	0.52, 0.52, 0.52, 0.5, 0.5, 0.5, 0.5,
	0.48, 0.48, 0.48, 0.48, 0.46, 0.46, 0.46,
	0.46, 0.46, 0.44, 0.44, 0.44, 0.44, 0.44,
	0.42, 0.42, 0.42, 0.42, 0.42, 0.4, 0.4,
	0.4, 0.4, 0.4, 0.4, 0.4, 0.38, 0.38,
	0.38, 0.38, 0.38, 0.38, 0.38, 0.36, 0.36,
	0.36, 0.36, 0.36, 0.36, 0.36, 0.34, 0.34,
	0.34, 0.34, 0.34, 0.34, 0.34, 0.34, 0.34,
	0.32, 0.32, 0.32, 0.32, 0.32, 0.32, 0.32,
	0.32, 0.32, 0.32, 0.3, 0.3, 0.3, 0.3,
	0.3, 0.3, 0.3, 0.3, 0.3, 0.3, 0.3,
	0.28, 0.28, 0.28, 0.28, 0.28, 0.28, 0.28,
	0.28, 0.28, 0.28, 0.28, 0.28, 0.28, 0.26,
	0.26, 0.26, 0.26, 0.26, 0.26, 0.26, 0.26,
	0.26, 0.26, 0.26, 0.26, 0.26, 0.26, 0.24,
	0.24, 0.24, 0.24, 0.24, 0.24, 0.24, 0.24,
	0.24, 0.24, 0.24, 0.24, 0.24, 0.24, 0.24,
	0.24, 0.24, 0.24, 0.22, 0.22, 0.22, 0.22,
	0.22, 0.22, 0.22, 0.22, 0.22, 0.22, 0.22,
	0.22, 0.22, 0.22, 0.22, 0.22, 0.22, 0.22,
	0.22, 0.22, 0.22, 0.2, 0.2, 0.2, 0.2,
	0.2, 0.2, 0.2, 0.2, 0.2, 0.2, 0.2,
	0.2, 0.2, 0.2, 0.2, 0.2, 0.2, 0.2,
	0.2, 0.2, 0.2, 0.2, 0.2, 0.2, 0.2
]

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
