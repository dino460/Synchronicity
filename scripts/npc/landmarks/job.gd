extends Landmark

class_name Job

@export var scheduler : Scheduler
## Expected amount of time this work expects its NPCs to stay.
## From 0 to 24.
@export_range(0, 23.99, 0.5)
var expected_work_amount : float
var expected_work_amount_converted : float
## Ratio of how much of 'expected_work_amount' is needed before reputation goes down
## From 0 to 1
@export_range(0, 1, 0.01)
var min_work_amount : float
## The latest time an NPC would want to arrive at this job.
## From 0 to 24.
@export_range(0, 23.99, 0.5)
var work_begin_time : float
var work_begin_time_converted : float

@export_range(0, 23.99, 0.5)
var max_lateness : float
var max_lateness_converted : float


const full_day_time : float = 24.0
var full_day_time_converted : float

@export var max_worker_distance : float

func _ready() -> void:
	super()
	scheduler = get_tree().get_root().get_node("Main/Scheduler")
	radius_of_influence = max_worker_distance

	full_day_time_converted        = scheduler.cycle_total_time
	expected_work_amount_converted = full_day_time_converted * expected_work_amount / 24.0
	work_begin_time_converted      = full_day_time_converted * work_begin_time / 24.0
	max_lateness_converted         = full_day_time_converted * max_lateness / 24.0

func is_job() -> bool:
	return true

func get_attraction(distance : float) -> float:
	var attraction = super(distance)
	var current_time = scheduler.get_current_time()

	var lateness_weight = max(1.0, (current_time - work_begin_time_converted) / (max_lateness_converted))
	var punctuality_weight = (work_begin_time_converted + current_time) / full_day_time_converted
	# print("JOB: ", attraction, " | ", lateness_weight, " | ", punctuality_weight)

	return attraction * lateness_weight * punctuality_weight


# func save():
# 	var super_save = super()
# 	var save_dict = {
# 		"expected_work_amount" : expected_work_amount,
# 		"min_work_time_accepted" : min_work_time_accepted,
# 		"work_begin_time" : work_begin_time,
# 		"max_lateness" : max_lateness,
# 		"max_worker_distance" : max_worker_distance,
# 	}
# 	return super_save + save_dict

func get_in_game_expected_work() -> float:
	return scheduler.cycle_total_time * expected_work_amount / 24.0

func has_worked_today(time_worked : float) -> bool:
	return time_worked >= (expected_work_amount * scheduler.cycle_total_time / 24.0)
