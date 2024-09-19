extends CharacterBody3D

class_name NPC

const base_move_speed : float = 8.0
const base_run_multiplier : float = 2.3

@export var npc_name : String
@export var id : int

# @export var scheduler : Scheduler
@export var timers : Dictionary

@export var current_age        : int
@export var cycles_to_next_age : int
@export var emotions : Emotions
@export var personality : Personality

@export var job                : Job
@export var home               : Home
@export var visits             : Array[Visit]
@export var points_of_interest : Array[Landmark]

@export var work_time_this_day : float = 0.0
@export var has_worked_today : bool = false

@onready var navigation_agent: NavigationAgent3D = $NavigationAgent3D

var current_target   : Node3D
var current_location : Node3D

var is_running : bool = false
var navigation_enabled : bool = false

var is_at_home : bool = false
var is_at_job : bool = false

var is_doing_stuff : bool = false


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
	# scheduler = get_tree().get_root().get_node("Main/Scheduler")
	id = get_tree().get_root().get_node("Main/Scheduler").request_id()
	# Make sure to not await during _ready.
	call_deferred("actor_setup")

func actor_setup():
	choose_target()
	navigation_agent.debug_enabled = true
	# Wait for the first physics frame so the NavigationServer can sync.
	await get_tree().physics_frame

	# Now that the navigation map is no longer empty, set the movement target.
	set_movement_target()

func set_movement_target():
	navigation_agent.set_target_position(current_target.position)
	navigation_enabled = true

func time_to_get_to_target() -> float:
	return position.distance_to(current_target.position) / get_speed()

# func want_to_go_to_job() -> bool:
# 	# Translates job arrive time from 24 hour value to in-game time
# 	var corrected_job_arrive_time = (job.time_want_to_arrive / 24.0) * scheduler.full_day_time
# 	# Translates job max late time from 24 hour value to in-game time
# 	var corrected_job_max_late_amount = (job.max_late_amount / 24.0) * scheduler.full_day_time
# 	# Calculates time to get to work through distance and movement spedd
# 	var time_to_get_to_job = position.distance_to(job.position) / get_speed()
# 	# Calculates how late in in-game time the npc will be
# 	var late_time = scheduler.get_current_time() - corrected_job_arrive_time + time_to_get_to_job

# 	# Adjusts the late time to a percentage of the maximum lateness value
# 	# After that, ajusts it by the lateness importance
# 	# Lastly, applies it to 1.0 for further correction
# 	var job_lateness_correction = 1.0 + (emotions.job_late_importance * late_time / corrected_job_max_late_amount)

# 	# Adds job love to lanetness correction
# 	# Should yield a value close to 1.0 (preferably smaller) when not yet late
# 	# Yields a value explodingly larger than 1.0 when late
# 	var weight = emotions.job_love  + job_lateness_correction

# 	# Divides the calculated weight by either 1.0 + double the home love or just 1.0 + home love
# 	# As the correction value is always between 1.0 and 2.0, it reduces the weight value
# 	# The final weight should be usually smaller than 1.0 when not late, getting closer and eventually surpassing it
# 	weight /= (1.0 + (2.0 * emotions.home_love)) if not home.timer.is_stopped() else (1.0 + emotions.home_love)

# 	# Checks if calculated weight surpases relevant thresshold
# 	# Applies a small random value for some spice
# 	return weight + randf_range(-0.03, 0.03) >= emotions.go_to_job_thresshold

# func want_to_go_to_home() -> bool:
# 	# Translates home arrive time from 24 hour value to game time
# 	var corrected_home_arrive_time = (home.time_want_to_arrive_home / 24.0) * scheduler.full_day_time
# 	# Translates job max late time from 24 hour value to in-game time
# 	var corrected_home_max_late_amount = (home.max_late_amount / 24.0) * scheduler.full_day_time
# 	# Calculates time to get to home through distance and movement spedd
# 	var time_to_get_to_home = position.distance_to(home.position) / get_speed()
# 	# Calculates how late in in-game time the npc will be
# 	var late_time = scheduler.get_current_time() - corrected_home_arrive_time + time_to_get_to_home

# 	# Adjusts the late time to a percentage of the maximum lateness value
# 	# After that, ajusts it by the lateness importance
# 	# Lastly, applies it to 1.0 for further correction
# 	var home_lateness_correction = 1.0 + (emotions.home_late_importance * late_time / corrected_home_max_late_amount)

# 	# Adds home love to lanetness correction
# 	# Should yield a value close to 1.0 (preferably smaller) when not yet late
# 	# Yields a value explodingly larger than 1.0 when late
# 	var weight = emotions.home_love  + home_lateness_correction

# 	# Divides the calculated weight by either 1.0 + double the job love or just 1.0 + job love
# 	# As the correction value is always between 1.0 and 2.0, it reduces the weight value
# 	# The final weight should be usually smaller than 1.0 when not late, getting closer and eventually surpassing it
# 	weight /= (1.0 + (2.0 * (emotions.job_love + job.timer.time_left))) if not job.timer.is_stopped() else (1.0 + emotions.job_love)

# 	# Checks if calculated weight surpases relevant thresshold
# 	# Applies a small random value for some spice
# 	return weight + randf_range(-0.03, 0.03)>= emotions.go_to_home_thresshold

func choose_target():
	var targets_to_choose : Dictionary

	for landmark in points_of_interest:
		targets_to_choose[landmark] = landmark.get_npc_want(self, current_location == landmark) / get_landmark_timer(landmark)
	targets_to_choose[home] = home.get_npc_want(self, current_location == home) / get_landmark_timer(home)
	targets_to_choose[job] = job.get_npc_want(self, current_location == job) / get_landmark_timer(job)
	# targets_to_choose.erase(current_location)

	current_target = targets_to_choose.keys()[0]

	# print_rich(current_target.name, " ", targets_to_choose[targets_to_choose.keys()[0]])

	for landmark in targets_to_choose:
		if targets_to_choose[landmark] > targets_to_choose[current_target]:
			print_rich(landmark.name, " ", targets_to_choose[landmark])
			current_target = landmark

	print_rich(">>> [color=red][b] %s [/b][/color]" % current_target.landmark_name)

func _process(delta: float) -> void:
	for timer in timers:
		# print(timers[timer])
		timers[timer] += delta

func _physics_process(_delta):
	if navigation_agent.is_navigation_finished() && navigation_enabled && not is_doing_stuff:
		add_visit()
		current_location = current_target
		is_doing_stuff = true

		timers[current_location] = 0.0

		choose_target()
		set_movement_target()

		# if not is_at_home and not is_at_job:
		# 	if current_target == home:
		# 		print_rich("[color=yellow][i]got at home - starting timer[/i][/color]")
		# 		print_rich(24 * (scheduler.full_day_time - scheduler.time_left) / scheduler.full_day_time)
		# 		home.is_at_home = true
		# 		home.timer.start(scheduler.full_day_time * home.min_home_amount / 24.0)
		# 	elif current_target == job:
		# 		print_rich("[color=yellow][i]got at job - starting timer[/i][/color]")
		# 		print_rich(24 * (scheduler.full_day_time - scheduler.time_left) / scheduler.full_day_time)
		# 		job.is_at_job = true
		# 		job.timer.start(scheduler.full_day_time * job.expected_work_amount / 24.0)

		# if is_at_home and want_to_go_to_job() and not has_worked_today:
		# 	print_rich("[color=red][b]at home - timer stopped[/b][/color]")
		# 	print_rich(24 * (scheduler.full_day_time - scheduler.time_left) / scheduler.full_day_time)
		# 	current_target = job
		# 	is_at_home = false
		# 	var home_time_this_day = home.min_home_amount - (home.timer.time_left * 24 / scheduler.full_day_time)
		# 	print_rich("\n[color=green]==================================================[/color]")
		# 	print_rich("[color=green]==================================================[/color]\n")
		# 	print_rich("[color=green]Time home today: [/color]", home_time_this_day)
		# 	print_rich("\n[color=green]==================================================[/color]")
		# 	print_rich("[color=green]==================================================[/color]\n")
		# 	home.timer.stop()
		# 	set_movement_target()
		# elif is_at_job and want_to_go_to_home():
		# 	print_rich("[color=red][b]at job - timer stopped[/b][/color]")
		# 	print_rich(24 * (scheduler.full_day_time - scheduler.time_left) / scheduler.full_day_time)
		# 	has_worked_today = true
		# 	current_target = home
		# 	is_at_job = false
		# 	work_time_this_day = job.expected_work_amount - (job.timer.time_left * 24 / scheduler.full_day_time)
		# 	print_rich("\n[color=green]==================================================[/color]")
		# 	print_rich("[color=green]==================================================[/color]\n")
		# 	print_rich("[color=green]Time worked today: [/color]", work_time_this_day)
		# 	print_rich("\n[color=green]==================================================[/color]")
		# 	print_rich("[color=green]==================================================[/color]\n")
		# 	job.timer.stop()
		# 	set_movement_target()

		return

	choose_target()

	if current_target != current_location and is_doing_stuff:
		set_movement_target()
		is_doing_stuff = false

	var current_agent_position: Vector3 = global_position
	var next_path_position: Vector3 = navigation_agent.get_next_path_position()

	velocity = current_agent_position.direction_to(next_path_position) * get_move_speed()
	move_and_slide()

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

func get_landmark_timer(landmark : Node3D) -> float:
	if timers.is_empty() or not timers.has(landmark):
		return 1.0

	return timers[landmark]
