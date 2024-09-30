extends CharacterBody3D

class_name NPC

const base_move_speed : float = 8.0
const base_run_multiplier : float = 2.3

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
@export var visits             : Array[Visit]
@export var points_of_interest : Array[Landmark]

@export var average_poi_distance : float

@export var work_time_this_day : float = 0.0
@export var has_worked_today : bool = false

@onready var navigation_agent: NavigationAgent3D = $NavigationAgent3D

@export var test_label : Label

var current_target   : Node3D
var current_location : Node3D

var is_running : bool = false
var navigation_enabled : bool = false

var is_at_home : bool = false
var is_at_job : bool = false

var is_doing_stuff : bool = false
var is_moving_about : bool = false


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

func time_to_get_to_target() -> float:
	return position.distance_to(current_target.position) / get_speed()

func choose_target():
	var targets_to_choose : Dictionary

	for landmark in points_of_interest:
		targets_to_choose[landmark] = landmark.get_npc_want(self, current_location == landmark, 0.0) / sqrt(get_landmark_timer(landmark, false))
	targets_to_choose[home] = home.get_npc_want(self, current_location == home, 0.0) / sqrt(get_landmark_timer(home, false))
	targets_to_choose[job] = job.get_npc_want(self, has_worked_today, 0.0) / sqrt(get_landmark_timer(job, false))

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

func _process(delta: float) -> void:
	for timer in timers:
		if is_doing_stuff:
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
	if navigation_agent.is_navigation_finished() && navigation_enabled && not is_doing_stuff:
		# print(path_timer)
		calculate_average_poi_distance()
		add_visit()
		current_location = current_target
		is_doing_stuff = true
		is_moving_about = false

		timers[current_location] = 0.0
		# print_rich("[color=cyan]Arrived at [b]%s[/b][/color] | %s" % [current_location.landmark_name, scheduler.get_current_time_24()])
		return

	check_for_path_while_doing_stuff()
	check_for_path_while_moving()

	var current_agent_position: Vector3 = global_position
	var next_path_position: Vector3 = navigation_agent.get_next_path_position()

	velocity = current_agent_position.direction_to(next_path_position) * get_move_speed()

func reset_has_worked_today():
	has_worked_today = false

func get_visit_by_landmark(landmark : Landmark) -> int:
	for visit in visits:
		if visit.landmark == landmark:
			return visit.landmark.number_of_visits

	return 0

func add_visit():
	if current_location == current_target:
		return

	for visit in visits:
		if visit.landmark == current_target:
			visit.number_of_visits += 1
			return

	visits.append(Visit.new(current_location))

func get_landmark_timer(landmark : Node3D, receive_zero : bool) -> float:
	if not timers.has(landmark):
		return 0.0 if receive_zero else 1.0

	return timers[landmark]

func scan_for_new_landmarks():
	pass

func check_for_path_while_doing_stuff():
	if is_doing_stuff:
		choose_target()
		if current_location != current_target:
			timers.erase(current_location)
			if current_location == job:
				has_worked_today = true
			set_movement_target()
			is_doing_stuff = false
			is_moving_about = true

func check_for_path_while_moving():
	if is_moving_about:
		choose_target()
		if current_location != current_target:
			set_movement_target()

func calculate_average_poi_distance():
	if points_of_interest.size() <= 0:
		average_poi_distance = 0.0
		return

	for poi in points_of_interest:
		average_poi_distance += self.position.distance_to(poi.position)
	average_poi_distance /= points_of_interest.size()
