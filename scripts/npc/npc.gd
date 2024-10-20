extends CharacterBody3D

class_name NPC

const base_move_speed : float = 8.0
const base_run_multiplier : float = 2.3

enum State {DOING_STUFF, MOVING_ABOUT, SLEEPING}
var current_state : State = State.DOING_STUFF

@export var npc_name : String
@export var id : int
var process_group : int

@export var timers : Dictionary
@export var scheduler : Scheduler

@export var current_age        : int
@export var cycles_to_next_age : int
@export var personality : Personality

@export var job                : Job
@export var home               : Home
@export var visits             : Dictionary
@export var points_of_interest : Array[Landmark]

@export var average_poi_distance : float

@export var has_worked_today : bool = false
var work_time_this_day : float = 0.0
var moving_about_time_this_day : float = 0.0
var awake_time_this_day : float = 0.0

@onready var navigation_agent: NavigationAgent3D = $NavigationAgent3D

@export var test_label : Label

var current_target   : Landmark
var current_location : Landmark
var last_location : Landmark

var is_running : bool = false
var navigation_enabled : bool = false

var is_at_home : bool = false
var is_at_job : bool = false

var want_to_sleep : bool = false
var sleep_amount_wanted : float = 0.0
var sleep_counter : float = 0.0

# var is_doing_stuff : bool = false
# var is_moving_about : bool = false


func mod_by_age() -> float:
	return minf(maxf((-sin(current_age / 31.85) * log(current_age / 100.0)) + 0.05, 0.5), 1.0)

func get_move_speed() -> float:
	return base_move_speed * mod_by_age()

func get_run_speed() -> float:
	return get_move_speed() * base_run_multiplier

func get_speed() -> float:
	return get_run_speed() if is_running else get_move_speed()

func _ready():
	add_to_group("persist")
	personality = get_child(0)
	# scheduler = get_tree().get_root().get_node("Main/Scheduler")
	scheduler = get_tree().get_root().get_node("Main/Scheduler")
	id = scheduler.request_id()
	process_group = scheduler.request_group()
	scheduler.call_deferred("bind_callable_to_group", process_group, run_pathfinding_logic)
	calculate_average_poi_distance()
	# Make sure to not await during _ready.
	call_deferred("actor_setup")

func actor_setup():
	choose_target()
	# navigation_agent.debug_enabled = true
	# Wait for the first physics frame so the NavigationServer can sync.
	await get_tree().physics_frame

	# Now that the navigation map is no longer empty, set the movement target.
	set_movement_target()

func set_movement_target():
	navigation_agent.set_target_position(current_target.position)
	navigation_enabled = true

func _process(delta: float) -> void:
	if want_to_sleep and current_location == home:
		sleep_counter += delta
		current_state = State.SLEEPING

		if sleep_counter >= sleep_amount_wanted:
			print("AWAKE | ", scheduler.get_current_time_24())
			want_to_sleep = false
			sleep_amount_wanted = 0.0
			sleep_counter = 0.0
			awake_time_this_day = 0.0
			current_state = State.DOING_STUFF
	elif not want_to_sleep and current_state == State.MOVING_ABOUT:
		moving_about_time_this_day += delta
	else:
		awake_time_this_day += delta

	for timer in timers:
		if current_state == State.DOING_STUFF:
			# print(timers[timer])
			timers[timer] += delta
			if not has_worked_today:
				has_worked_today = job.has_worked_today(get_landmark_timer(job, true))

func _physics_process(_delta):
	# if current_target != null:
	# 	print_rich(">>> want go: [color=red][b] %s [/b][/color]" % current_target.landmark_name)
	# if current_location != null:
	# 	print_rich(">>> I am at: [color=red][b] %s [/b][/color]" % current_location.landmark_name)

	if current_location != current_target:
		position += velocity * _delta

func run_pathfinding_logic():
	if want_to_sleep:
		return

	if navigation_agent.is_navigation_finished() && navigation_enabled && current_state != State.DOING_STUFF:
		calculate_average_poi_distance()
		# add_visit()
		current_location = current_target
		# is_doing_stuff = true
		# is_moving_about = false
		current_state = State.DOING_STUFF

		timers[current_location] = 0.0

		if current_location == job:
			# print_rich("[color=cyan]Arrived at [/color][color=red][b]%s[/b][/color] | %s" % [current_location.landmark_name, scheduler.get_current_time_24()])
			pass
		elif current_location == home:
			if has_worked_today:
				want_to_sleep = ((work_time_this_day * 0.15) + moving_about_time_this_day + (awake_time_this_day / 2.0)) / scheduler.full_day_time > personality.mind * personality.energy
				sleep_amount_wanted = max(4.0 * scheduler.full_day_time / 24.0, min(7.0 * scheduler.full_day_time / 24.0, work_time_this_day + moving_about_time_this_day))
				# print(sleep_amount_wanted)
				# print(moving_about_time_this_day)
			# print_rich("[color=cyan]Arrived at [/color][color=green][b]%s[/b][/color] | %s" % [current_location.landmark_name, scheduler.get_current_time_24()])
		# else:
			# print_rich("[color=cyan]Arrived at [/color][color=yellow][b]%s[/b][/color] | %s" % [current_location.landmark_name, scheduler.get_current_time_24()])
		return

	check_for_path_while_doing_stuff()
	check_for_path_while_moving()

	var current_agent_position: Vector3 = global_position
	var next_path_position: Vector3 = navigation_agent.get_next_path_position()

	velocity = current_agent_position.direction_to(next_path_position) * get_move_speed()

func check_for_path_while_doing_stuff():
	if current_state == State.DOING_STUFF:
		choose_target()
		if current_location != current_target:
			if current_location == job:
				work_time_this_day = timers[current_location]
				has_worked_today = true
				# print(work_time_this_day * 24.0 / scheduler.full_day_time)
			timers.erase(current_location)
			set_movement_target()
			last_location = current_location
			# is_doing_stuff = false
			# is_moving_about = true
			current_state = State.MOVING_ABOUT

func check_for_path_while_moving():
	if current_state == State.MOVING_ABOUT:
		choose_target()
		if current_location != current_target:
			set_movement_target()

func time_to_get_to_target() -> float:
	return position.distance_to(current_target.position) / get_speed()

func choose_target():
	var targets_to_choose : Dictionary

	if last_location == null:
		last_location = home

	for landmark in points_of_interest:
		var interference = 0.0

		if has_worked_today and scheduler.get_current_time() <= (scheduler.full_day_time * home.time_want_to_arrive / 24.0):
			interference += personality.bravery + personality.energy

		targets_to_choose[landmark] = landmark.get_npc_want(self, current_location == landmark, interference + generate_interference()) / sqrt(get_landmark_timer(landmark, false))

	targets_to_choose[home] = home.get_npc_want(self, current_location == home, generate_interference()) / sqrt(get_landmark_timer(home, false))
	targets_to_choose[job] = job.get_npc_want(self, has_worked_today, generate_interference()) / sqrt(get_landmark_timer(job, false))

	if current_state == State.MOVING_ABOUT:
		targets_to_choose[last_location] /= 10.0

	current_target = targets_to_choose.keys()[0]
	var text : String = ""
	# print_rich(current_target.name, " ", targets_to_choose[targets_to_choose.keys()[0]])
	# text += current_target.name + " : " + targets_to_choose[targets_to_choose.keys()[0]] + "\n"
	for landmark in targets_to_choose:
		# print_rich(landmark.landmark_name, " ", targets_to_choose[landmark])
		text += str(landmark.landmark_name, " : ", targets_to_choose[landmark], "\n")
		if targets_to_choose[landmark] > targets_to_choose[current_target]:
			# print_rich("[color=red][b][i]%s :: %f[/i][/b][/color]" % [landmark.landmark_name, targets_to_choose[landmark]])
			current_target = landmark

	if test_label != null:
		test_label.text = text

func generate_interference() -> float:
	return randf_range(0.0, 1.0) * min(0.3, personality.chaos * exp(-randf_range(0.0, 2.0)) / (sqrt(scheduler.full_day_time / 100)))

func reset_has_worked_today():
	has_worked_today = false

func get_visit_by_landmark(landmark : Landmark) -> int:
	for visit in visits:
		if visit.landmark == landmark:
			return visit.landmark.number_of_visits

	return 0

func add_visit(visited_landmark : Landmark):
	if not visits.has(visited_landmark):
		visits[visited_landmark] = 1
	else:
		visits[visited_landmark] += 1

func get_landmark_timer(landmark : Node3D, receive_zero : bool) -> float:
	if not timers.has(landmark):
		return 0.0 if receive_zero else 1.0

	return timers[landmark]

func scan_for_new_landmarks():
	pass

func calculate_average_poi_distance():
	if points_of_interest.size() <= 0:
		average_poi_distance = 0.0
		return

	for poi in points_of_interest:
		average_poi_distance += self.position.distance_to(poi.position)
	average_poi_distance /= points_of_interest.size()
