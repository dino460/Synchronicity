extends CharacterBody3D

class_name NPC

const base_move_speed : float = 8.0
const base_run_multiplier : float = 2.3

@export var scheduler : Scheduler

@export var age      : int
@export var emotions : Emotions

@export var job                : Job
@export var home               : Home
@export var current_target     : Node3D
@export var points_of_interest : Array[Node3D]

@export var work_time_this_day : float = 0.0
@export var has_worked_today : bool = false

@onready var navigation_agent: NavigationAgent3D = $NavigationAgent3D

var is_running : bool = false
var navigation_enabled : bool = false


func mod_by_age() -> float:
	return minf(maxf((-sin(age / 31.85) * log(age / 100.0)) + 0.05, 0.5), 1.0)

func get_move_speed() -> float:
	return base_move_speed * mod_by_age()
	
func get_run_speed() -> float:
	return get_move_speed() * base_run_multiplier
	
func get_speed() -> float:
	return get_run_speed() if is_running else get_move_speed()


func _ready():
	scheduler = get_tree().get_root().get_node("Main/Scheduler")
	print(scheduler)
	# Make sure to not await during _ready.
	current_target = home
	call_deferred("actor_setup")

func actor_setup():
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

func want_to_go_to_job() -> bool:
	var corrected_job_arrive_time = (job.time_want_to_arrive_job / 24.0) * scheduler.full_day_time
	var current_time = scheduler.full_day_time - scheduler.time_left
	var time_to_get_to_job = position.distance_to(job.position) / get_speed()
	var late_time = current_time - corrected_job_arrive_time + time_to_get_to_job
	
	var job_lateness_correction = 1.0 + (late_time * emotions.being_late_importance / job.max_late_amount)
	var weight = emotions.job_love  + job_lateness_correction
	
	
	#print(name)
	#print("time to get to job: ", time_to_get_to_job)
	#print("late time: ", late_time)
	#print("job weight: ", weight)
	
	weight /= (1.0 - emotions.home_love) if not home.timer.is_stopped() else (1.0 - emotions.home_love) / 2.0
	
	#print("weight: ", weight)
		
	#print()
	return weight >= emotions.go_to_job_thresshold
	
func want_to_go_to_home() -> bool:
	var corrected_home_arrive_time = (home.time_want_to_arrive_home / 24.0) * scheduler.full_day_time
	var current_time = scheduler.full_day_time - scheduler.time_left
	var time_to_get_to_home = position.distance_to(home.position) / get_speed()
	var late_time = current_time - corrected_home_arrive_time + time_to_get_to_home
	
	var home_lateness_correction = 1.0 + (late_time * emotions.being_late_importance / home.max_late_amount)
	var weight = emotions.job_love  + home_lateness_correction
	
	#print("late time: ", late_time)
	#print("job weight: ", weight)
	
	weight /= (1.0 - emotions.job_love) if not job.timer.is_stopped() else (1.0 - emotions.job_love) / 2.0
	
	#print("weight: ", weight)
	
	#print()
	return weight >= emotions.go_to_home_thresshold

func _physics_process(_delta):
	if navigation_agent.is_navigation_finished() && navigation_enabled:
		if not home.is_at_home and not job.is_at_job:
			if current_target == home:
				print("got at home - starting timer")
				home.is_at_home = true
				home.timer.start(scheduler.full_day_time * home.min_home_amount / 24.0)
			elif current_target == job:
				print("got at job - starting timer")
				job.is_at_job = true
				job.timer.start(scheduler.full_day_time * job.min_work_amount / 24.0)
		
		if home.is_at_home and want_to_go_to_job() and not has_worked_today:
			print("at home - timer stopped")
			current_target = job
			home.is_at_home = false
			home.timer.stop()
			set_movement_target()
		elif job.is_at_job and want_to_go_to_home():
			print("at job - timer stopped")
			has_worked_today = true
			current_target = home
			job.is_at_job = false
			work_time_this_day = job.min_work_amount - (job.timer.time_left * 24 / scheduler.full_day_time)
			print("\n=======================\nTime worked today: ", work_time_this_day, "\n=======================\n")
			job.timer.stop()
			set_movement_target()
		
		return

	var current_agent_position: Vector3 = global_position
	var next_path_position: Vector3 = navigation_agent.get_next_path_position()

	velocity = current_agent_position.direction_to(next_path_position) * get_move_speed()
	move_and_slide()
