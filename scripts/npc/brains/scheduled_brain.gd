extends Node

class_name ScheduledBrain

enum TaskState { WORKING, IDLING, MOVING, AT_HOME, SLEEPING }
var current_task_state : TaskState = TaskState.IDLING

var landmark_current : Landmark
var landmark_last    : Landmark
var landmark_target  : Landmark

var home : Landmark
var job : Landmark
@export var points_of_interest : Array[Landmark]

var has_worked_today : bool
var want_to_work : bool = false

var want_to_sleep       : bool = false
var sleep_amount_wanted : float = 0.0
var sleep_counter       : float = 0.0

func setup(npc_ref : NPC):
	points_of_interest.append_array(npc_ref.points_of_interest)
	points_of_interest.append(npc_ref.home)
	points_of_interest.append(npc_ref.job)

	if landmark_current == null:
		var home_candidate : Landmark = check_for_home()
		if home_candidate == null:
			push_error("NPC has no home")
		else:
			landmark_current = home_candidate
			home = home_candidate


func check_for_home() -> Landmark:
	for landmark in points_of_interest:
		if landmark.is_home():
			return landmark
	return null


func handle_schedule(npc_ref : NPC):
	landmark_current = npc_ref.current_location

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

		TaskState.MOVING:
			pass

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


func check_for_sleep(npc_ref : NPC):
	pass


func choose_next_location(npc_ref : NPC) -> Landmark:
	landmark_current = npc_ref.current_location
	# if home == null or job == null:
		# return null

	var chosen_location : Landmark = null
	var chosen_location_attraction : float = 0.0

	# if landmark_last == null:
		# landmark_last = home

	print(points_of_interest.size())
	for landmark in points_of_interest:
		var special_check_var : bool = false
		# if landmark == home && landmark_current == home:
		# 	special_check_var = true
		# elif landmark == job:
		# 	special_check_var = npc_ref.has_worked_today

		var landmark_attraction : float = landmark.get_npc_attraction(npc_ref, landmark == landmark_current, special_check_var)
		if landmark_attraction > chosen_location_attraction:
			chosen_location = landmark
			chosen_location_attraction = landmark_attraction

	if chosen_location == landmark_current:
		return null

	return chosen_location
