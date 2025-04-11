extends Entity

class_name NPC

const base_move_speed     : float = 3.3
const base_run_multiplier : float = 2.3

signal idling
signal walking
signal death

enum State {DOING_STUFF, MOVING_ABOUT, SLEEPING, DEAD, FIGHTING}
var current_state : State = State.DOING_STUFF

@export var test_label : Label

@export_group("NPC Identity")
@export var npc_name : String
@export var id       : int
var process_group    : int

@export_group("NPC Scheduling")
@export var timers    : Dictionary
@export var scheduler : Scheduler

@export_group("NPC Characteristics")
@export var current_age        : int
@export var cycles_to_next_age : int
@export var personality        : Personality

@export_group("NPC Landmarks")
@export var job                : Job
@export var home               : Home
@export var visits             : Dictionary
@export var points_of_interest : Array[Landmark]

@export var average_poi_distance : float

@export_group("NPC Work")
@export var has_worked_today   : bool = false

var work_time_this_day         : float = 0.0
var moving_about_time_this_day : float = 0.0
var awake_time_this_day        : float = 0.0

var want_to_sleep       : bool = false
var sleep_amount_wanted : float = 0.0
var sleep_counter       : float = 0.0

@export_group("NPC Navigation")
@onready var navigation_agent: NavigationAgent3D = $NavigationAgent3D

var current_target   : Landmark
var current_location : Landmark
var last_location    : Landmark

var is_at_job  : bool = false
var is_at_home : bool = false

@export_group("NPC Movement")
var is_running         : bool = false
var direction          : Vector3 = Vector3.ZERO
var navigation_enabled : bool = false
var is_resting         : bool = false

@export_group("NPC Combat")
var attack_targets : Dictionary[Entity, int]
var current_attack_target : Entity

@export_group("NPC Rendering")
@onready var mesh_pivot_ref = $MeshPivot
var is_in_frustum : bool = true


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

	get_node("AnimationHandler").caller_prefix = "NPC/"

	personality = get_node("Personality")
	scheduler = get_tree().get_root().get_node("Main/Scheduler")
	id = scheduler.request_id()
	process_group = scheduler.request_group()

	scheduler.call_deferred("bind_callable_to_group", process_group, run_pathfinding_logic)

	calculate_average_poi_distance()

	if last_location == null:
		last_location = home

	call_deferred("actor_setup") # Make sure to not await during _ready.

func actor_setup():
	choose_target()
	await get_tree().physics_frame # Wait for the first physics frame so the NavigationServer can sync.
	if current_target == null:
		return
	set_movement_target(current_target.position) # Now that the navigation map is no longer empty, set the movement target.

func set_movement_target(target_position : Vector3):
	if target_position == null:
		return

	navigation_agent.set_target_position(target_position)
	navigation_enabled = true

func _process(delta: float) -> void:
	if want_to_sleep and current_location == home:
		sleep_counter += delta
		current_state = State.SLEEPING
		if sleep_counter >= sleep_amount_wanted:
			reset_sleep()

	elif not want_to_sleep and current_state == State.MOVING_ABOUT:
		moving_about_time_this_day += delta
	else:
		awake_time_this_day += delta

	for timer in timers:
		if current_state != State.DOING_STUFF:
			continue
		timers[timer] += delta
		if has_worked_today:
			continue
		has_worked_today = job.has_worked_today(get_landmark_timer(job, true))

		# if current_state == State.DOING_STUFF:
		# 	# print(timers[timer])
		# 	timers[timer] += delta
		# 	if not has_worked_today:
		# 		has_worked_today = job.has_worked_today(get_landmark_timer(job, true))
	if current_attack_target != null and attack_targets.size() > 0:
		if attack_targets[current_attack_target] >= 0: # Change this to a significant amount of damage (use Personality)
			current_state = State.FIGHTING

func _physics_process(delta):
	if current_target != null or current_state == State.FIGHTING:
		direction = (navigation_agent.get_next_path_position() - position).normalized()
	mesh_pivot_ref.rotation.y = lerp_angle(mesh_pivot_ref.rotation.y, atan2(-direction.x, -direction.z), delta * 20.0)

	if current_location != current_target and not is_resting:
		position += velocity * delta

	if is_in_frustum:
		if current_state == State.DEAD:
			pass
		elif current_state == State.MOVING_ABOUT or current_state == State.FIGHTING:
			walking.emit()
		else:
			idling.emit()

func run_pathfinding_logic():
	if current_state == State.DEAD:
		current_target = null
		velocity = Vector3.ZERO
		navigation_enabled = false
		scheduler.call_deferred("unbind_callable_from_group", process_group, run_pathfinding_logic)
		return
	if want_to_sleep:
		return

	if navigation_agent.is_navigation_finished() and navigation_enabled and current_state != State.DOING_STUFF and current_state != State.FIGHTING:
		calculate_average_poi_distance()
		# add_visit()
		current_location = current_target
		current_state = State.DOING_STUFF

		timers[current_location] = 0.0

		if current_location == job:
			pass
		elif current_location == home:
			if has_worked_today:
				want_to_sleep = ((work_time_this_day * 0.15) + moving_about_time_this_day + (awake_time_this_day / 2.0)) / scheduler.full_day_time > personality.mind * personality.energy
				sleep_amount_wanted = max(4.0 * scheduler.full_day_time / 24.0, min(7.0 * scheduler.full_day_time / 24.0, work_time_this_day + moving_about_time_this_day))
		return

	if current_state == State.DOING_STUFF:
		check_for_path_while_doing_stuff()
	elif current_state == State.MOVING_ABOUT:
		check_for_path_while_moving()
	elif current_state == State.FIGHTING:
		handle_combat()

	var current_agent_position: Vector3 = global_position
	var next_path_position: Vector3 = navigation_agent.get_next_path_position()

	velocity = current_agent_position.direction_to(next_path_position) * get_move_speed()
	print(velocity)

func handle_combat():
	set_movement_target(current_attack_target.position)
	current_target = null

func check_for_path_while_doing_stuff():
	choose_target()
	if current_location == current_target:
		return

	if current_location == job:
		work_time_this_day = timers[current_location]
		has_worked_today = true

	timers.erase(current_location)
	set_movement_target(current_target.position)
	last_location = current_location
	current_state = State.MOVING_ABOUT

func check_for_path_while_moving():
	choose_target()
	if current_location == current_target:
		return

	set_movement_target(current_target.position)

func time_to_get_to_target() -> float:
	return position.distance_to(current_target.position) / get_speed()

func choose_target():
	if home == null or job == null:
		return
	if last_location == null:
		last_location = home

	var targets_to_choose : Dictionary

	var interference = 0.0
	if has_worked_today and scheduler.get_current_time() <= (scheduler.full_day_time * home.time_want_to_arrive / 24.0):
		interference = personality.bravery + personality.energy

	for landmark in points_of_interest:
		targets_to_choose[landmark] = landmark.get_npc_want(self, current_location == landmark, interference + generate_interference()) / sqrt(get_landmark_timer(landmark, false))

	targets_to_choose[home] = home.get_npc_want(self, current_location == home, generate_interference()) / sqrt(get_landmark_timer(home, false))
	targets_to_choose[job] = job.get_npc_want(self, has_worked_today, generate_interference()) / sqrt(get_landmark_timer(job, false))

	if current_state == State.MOVING_ABOUT:
		targets_to_choose[last_location] /= 10.0

	current_target = targets_to_choose.keys()[0]
	for landmark in targets_to_choose:
		if targets_to_choose[landmark] > targets_to_choose[current_target]:
			current_target = landmark

func generate_interference() -> float:
	return randf_range(0.0, 1.0) * min(0.3, personality.chaos * exp(-randf_range(0.0, 2.0)) / (sqrt(scheduler.full_day_time / 100)))

func reset_has_worked_today():
	has_worked_today = false

func reset_sleep():
	print("AWAKE | ", scheduler.get_current_time_24())
	want_to_sleep = false
	sleep_amount_wanted = 0.0
	sleep_counter = 0.0
	awake_time_this_day = 0.0
	current_state = State.DOING_STUFF

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

func _on_trigger_death() -> void:
	current_state = State.DEAD
	death.emit()

func _on_damage_taken(damage : int, new_attacker : Entity) -> void:
	print("taking damage: ", damage, " from ", new_attacker)
	if attack_targets.has(new_attacker):
		attack_targets[new_attacker] += damage
	attack_targets[new_attacker] = damage

	if current_attack_target == null:
		current_attack_target = new_attacker
		return

	for attacker in attack_targets:
		if attack_targets[attacker] > attack_targets[current_attack_target]:
			current_attack_target = attacker
