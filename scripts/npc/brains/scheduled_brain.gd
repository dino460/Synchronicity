extends Node

class_name ScheduledBrain

enum TaskState { WORKING, IDLING, MOVING, AT_HOME, SLEEPING }
var current_task_state : TaskState = TaskState.IDLING

var landmark_current : Landmark
var landmark_last    : Landmark
var landmark_target  : Landmark

@export var this_npc_ref : NPC

var home : Landmark
var job : Landmark
@export var landmarks_of_interest : Array[Landmark]

var want_to_work : bool = false

var want_to_sleep       : bool = false
var sleep_amount_wanted : float = 0.0
var sleep_counter       : float = 0.0

var landmarks_attractions : Dictionary[Landmark, float] = {null : 0.0}
var landmarks_timers : Dictionary[Landmark, float] = {null : 100000000.0}

@export_range(1, 60)
var number_of_attraction_updates : int = 30
var attraction_update_counter : int = 0

var tiredness : float = 0.0


func setup():
	landmarks_of_interest.append_array(this_npc_ref.points_of_interest)
	landmarks_of_interest.append(this_npc_ref.home)
	landmarks_of_interest.append(this_npc_ref.job)

	if landmark_current == null:
		var home_candidate : Landmark = check_for_home()
		if home_candidate == null:
			push_error("NPC has no home")
		else:
			landmark_current = home_candidate
			home = home_candidate

	call_deferred("update_landmark_attraction")


## ONLY CALL AT _physics_process
func process_update_landmark_attraction():
	attraction_update_counter += 1

	if attraction_update_counter < 60 / number_of_attraction_updates:
		return

	attraction_update_counter = 0
	update_landmark_attraction()

func update_landmark_attraction():
	for landmark in landmarks_of_interest:
		var distance_weight = this_npc_ref.personality.energy * landmark.get_attraction(this_npc_ref.position.distance_to(landmark.position), this_npc_ref)
		var loyalty_weight = this_npc_ref.personality.loyalty * landmark.get_npc_reputation(this_npc_ref.id)
		var avoidance_weight = this_npc_ref.personality.aggression / landmark.get_npc_reputation(this_npc_ref.id)

		landmarks_attractions[landmark] = distance_weight + loyalty_weight - avoidance_weight
		if not landmarks_timers.has(landmark):
			landmarks_timers[landmark] = 1.0

	match current_task_state:
		TaskState.MOVING:
			# landmarks_attractions[landmark_target] /= (1 - this_npc_ref.personality.loyalty)
			pass
		TaskState.IDLING:
			pass
	landmarks_attractions[landmark_current] /= landmarks_timers[landmark_current]


func check_for_home() -> Landmark:
	for landmark in landmarks_of_interest:
		if landmark.is_home():
			return landmark
	return null

func reset_brain():
	current_task_state = TaskState.IDLING
	landmark_current = null
	landmark_target = null

func handle_schedule(delta : float) -> Dictionary:
	# for landmark in landmarks_attractions:
	# 	print(landmark, ": ", landmarks_attractions[landmark], " | Timer: ", landmarks_timers[landmark])
	# print()

	# landmark_current = this_npc_ref.current_location
	if landmark_current == null:
		landmark_current = check_for_home()

	if want_to_sleep:
		current_task_state = TaskState.MOVING
		landmark_target = home
	elif want_to_work:
		current_task_state = TaskState.MOVING
		landmark_target = job

	tick_timers(delta)
	change_landmark_target()
	match current_task_state:
		TaskState.WORKING:
			tiredness += delta / this_npc_ref.personality.energy

		TaskState.IDLING:
			# change_landmark_target()


			landmark_current.run()
			# landmarks_timers[landmark_current] += delta

			if landmark_current != landmark_target:
				current_task_state = TaskState.MOVING
			elif landmark_current == home:
				current_task_state = TaskState.AT_HOME
			elif landmark_current == job:
				current_task_state = TaskState.WORKING

		TaskState.MOVING:
			# change_landmark_target()

			if landmark_target == landmark_current:
				current_task_state = TaskState.IDLING

		TaskState.AT_HOME:
			if landmark_current != landmark_target:
				current_task_state = TaskState.MOVING
				landmark_last = landmark_current
				# landmark_current = null

		TaskState.SLEEPING:
			if not want_to_sleep:
				current_task_state = TaskState.IDLING
			elif landmark_current == home:
				print("sleepy time")
				# run routine to make NPC go to bed and sleep
			else:
				landmark_target = home

	return {
		"current_task_state" : current_task_state,
		"landmark_current" : landmark_current,
		"landmark_last" : landmark_last,
		"landmark_target" : landmark_target
	}

func arrive_at_landmark_target():
	landmark_current = landmark_target

func check_for_sleep():
	pass

func change_landmark_target():
	if landmarks_attractions.size() <= 1:
		landmark_target = landmark_current
		return
	for landmark in landmarks_of_interest:
		if landmarks_attractions[landmark] > landmarks_attractions[landmark_target]:
			landmark_target = landmark


func tick_timers(delta : float):
	for landmark in landmarks_timers:
		if landmark == null:
			continue
		if landmark == landmark_current:
			landmarks_timers[landmark] += delta
			continue
		if landmarks_timers[landmark] > 1.0:
			landmarks_timers[landmark] -= delta

# func choose_next_location(this_npc_ref : NPC) -> Landmark:
# 	landmark_current = this_npc_ref.current_location
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
# 		# 	special_check_var = this_npc_ref.has_worked_today

# 		var landmark_attraction : float = landmark.get_npc_attraction(this_npc_ref, landmark == landmark_current, special_check_var)
# 		if landmark_attraction > chosen_location_attraction:
# 			chosen_location = landmark
# 			chosen_location_attraction = landmark_attraction

# 	if chosen_location == landmark_current:
# 		return null

# 	return chosen_location
