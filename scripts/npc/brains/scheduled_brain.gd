extends Node

class_name ScheduledBrain

enum TaskState { WORKING, IDLING, MOVING, AT_HOME, SLEEPING }
var current_task_state : TaskState = TaskState.IDLING

var landmark_current : Landmark
var landmark_last    : Landmark
var landmark_target  : Landmark

var home : Landmark
var job : Landmark
@export var landmarks_of_interest : Array[Landmark]

var has_worked_today : bool
var want_to_work : bool = false

var want_to_sleep       : bool = false
var sleep_amount_wanted : float = 0.0
var sleep_counter       : float = 0.0

var landmarks_attractions : Dictionary[Landmark, float] = {null : -100000000}
var landmarks_timers : Dictionary[Landmark, float] = {null : 100000000}

@export_range(1, 60)
var number_of_attraction_updates : int = 30
var attraction_update_counter : int = 0

func setup(npc_ref : NPC):
	landmarks_of_interest.append_array(npc_ref.points_of_interest)
	landmarks_of_interest.append(npc_ref.home)
	landmarks_of_interest.append(npc_ref.job)

	if landmark_current == null:
		var home_candidate : Landmark = check_for_home()
		if home_candidate == null:
			push_error("NPC has no home")
		else:
			landmark_current = home_candidate
			home = home_candidate

	for landmark in landmarks_of_interest:
		landmarks_timers[landmark] = 0.0
		var distance_weight = npc_ref.personality.energy * landmark.attraction_by_distance(npc_ref.position.distance_to(landmark.position))
		var loyalty_weight = npc_ref.personality.loyalty * landmark.get_npc_reputation(npc_ref.id)
		var avoidance_weight = npc_ref.personality.aggression / landmark.get_npc_reputation(npc_ref.id)

		landmarks_attractions[landmark] = distance_weight + loyalty_weight - avoidance_weight


## ONLY CALL AT _physics_process
func update_landmark_attraction(npc_ref : NPC):
	attraction_update_counter += 1

	if attraction_update_counter >= 60-number_of_attraction_updates:
		for landmark in landmarks_of_interest:
			var distance_weight = npc_ref.personality.energy * landmark.attraction_by_distance(npc_ref.position.distance_to(landmark.position))
			var loyalty_weight = npc_ref.personality.loyalty * landmark.get_npc_reputation(npc_ref.id)
			var avoidance_weight = npc_ref.personality.aggression / landmark.get_npc_reputation(npc_ref.id)

			landmarks_attractions[landmark] = distance_weight + loyalty_weight - avoidance_weight


func check_for_home() -> Landmark:
	for landmark in landmarks_of_interest:
		if landmark.is_home():
			return landmark
	return null


func handle_schedule(npc_ref : NPC, delta : float) -> Array:
	landmark_current = npc_ref.current_location
	if landmark_current == null:
		return []

	if want_to_sleep:
		current_task_state = TaskState.MOVING
		landmark_target = home
	elif want_to_work:
		current_task_state = TaskState.MOVING
		landmark_target = job

	match current_task_state:
		TaskState.WORKING:
			pass

		TaskState.IDLING:
			landmark_current.run()
			landmarks_timers[landmark_current] += delta
			landmarks_attractions[landmark_current] /= landmarks_timers[landmark_current]

			for landmark in landmarks_of_interest:
				if landmarks_attractions[landmark] > landmarks_attractions[landmark_target]:
					landmark_target = landmark

			if landmark_current != landmark_target:
				current_task_state = TaskState.MOVING

		TaskState.MOVING:
			for landmark in landmarks_of_interest:
				if landmarks_attractions[landmark] > landmarks_attractions[landmark_target]:
					landmark_target = landmark

		TaskState.AT_HOME:
			pass

		TaskState.SLEEPING:
			if not want_to_sleep:
				current_task_state = TaskState.IDLING
			elif landmark_current == home:
				print("sleepy time")
				# run routine to make NPC go to bed and sleep
			else:
				landmark_target = home

	return [TaskState.find_key(current_task_state), landmark_current, landmark_last, landmark_target]


func check_for_sleep(npc_ref : NPC):
	pass


# func choose_next_location(npc_ref : NPC) -> Landmark:
# 	landmark_current = npc_ref.current_location
# 	# if home == null or job == null:
# 		# return null

# 	var chosen_location : Landmark = null
# 	var chosen_location_attraction : float = 0.0

# 	# if landmark_last == null:
# 		# landmark_last = home

# 	print(landmarks_of_interest.size())
# 	for landmark in landmarks_of_interest:
# 		var special_check_var : bool = false
# 		# if landmark == home && landmark_current == home:
# 		# 	special_check_var = true
# 		# elif landmark == job:
# 		# 	special_check_var = npc_ref.has_worked_today

# 		var landmark_attraction : float = landmark.get_npc_attraction(npc_ref, landmark == landmark_current, special_check_var)
# 		if landmark_attraction > chosen_location_attraction:
# 			chosen_location = landmark
# 			chosen_location_attraction = landmark_attraction

# 	if chosen_location == landmark_current:
# 		return null

# 	return chosen_location
