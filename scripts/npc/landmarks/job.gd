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


func get_npc_want(npc : NPC, is_working_or_need_to_work : bool, interference : float) -> float:
	var scheduler_current_time = scheduler.get_current_time()
	var scheduler_time_left = scheduler.time_left
	var scheduler_full_day_time = scheduler.cycle_total_time

	var excess_poi_visit_time_correction = npc.points_of_interest.size() * npc.average_poi_distance * npc.personality.energy * npc.personality.bravery / npc.get_speed()
	var time_want_to_arrive_corrected = (scheduler_full_day_time * work_begin_time / 24.0) - time_to_arrive(npc) - excess_poi_visit_time_correction
	var lateness = scheduler_current_time - time_want_to_arrive_corrected
	var lateness_weight = 0.0 if is_working_or_need_to_work else lateness * npc.personality.mind
	var time_weight : float

	var in_game_time_want_to_stop = (scheduler_full_day_time * (work_begin_time + expected_work_amount) / 24.0)
	if scheduler_current_time > in_game_time_want_to_stop:
		var time_left = scheduler_time_left if scheduler_time_left > 0.0 else 0.1
		time_weight = -1 * in_game_time_want_to_stop / (time_left * sqrt(npc.personality.mind))
	elif scheduler_current_time >= time_want_to_arrive_corrected:
		time_weight = scheduler_time_left / (sqrt(npc.personality.mind) * scheduler_full_day_time)
	else:
		time_weight = pow(npc.personality.soul, 2) * scheduler.get_current_time() / scheduler_full_day_time

	return super(npc, is_working_or_need_to_work, interference) + lateness_weight + time_weight


func get_npc_attraction(npc_ref : NPC, _is_current_location : bool, is_working_or_need_to_work : bool) -> float:
	var scheduler_current_time = scheduler.get_current_time()
	var scheduler_time_left = scheduler.time_left
	var scheduler_full_day_time = scheduler.cycle_total_time

	var excess_poi_visit_time_correction = npc_ref.points_of_interest.size() * npc_ref.average_poi_distance * npc_ref.personality.energy * npc_ref.personality.bravery / npc_ref.get_speed()
	var time_want_to_arrive_corrected = (scheduler_full_day_time * work_begin_time / 24.0) - time_to_arrive(npc_ref) - excess_poi_visit_time_correction
	var lateness = scheduler_current_time - time_want_to_arrive_corrected
	var lateness_weight = 0.0 if is_working_or_need_to_work else lateness * npc_ref.personality.mind
	var time_weight : float

	var in_game_time_want_to_stop = (scheduler_full_day_time * (work_begin_time + expected_work_amount) / 24.0)
	if scheduler_current_time > in_game_time_want_to_stop:
		var time_left = scheduler_time_left if scheduler_time_left > 0.0 else 0.1
		time_weight = -1 * in_game_time_want_to_stop / (time_left * sqrt(npc_ref.personality.mind))
	elif scheduler_current_time >= time_want_to_arrive_corrected:
		time_weight = scheduler_time_left / (sqrt(npc_ref.personality.mind) * scheduler_full_day_time)
	else:
		time_weight = pow(npc_ref.personality.soul, 2) * scheduler.get_current_time() / scheduler_full_day_time

	return super(npc_ref, _is_current_location, is_working_or_need_to_work) + lateness_weight + time_weight


func is_job() -> bool:
	return true

func get_attraction(distance : float, npc_ref : NPC) -> float:
	var attraction = super(distance, npc_ref)
	var current_time = scheduler.get_current_time()
	var _time_to_arrive = time_to_arrive(npc_ref)

	var lateness_weight = max(1.0, (current_time - work_begin_time_converted + _time_to_arrive) / (max_lateness_converted))
	var punctuality_weight = (work_begin_time_converted - _time_to_arrive + current_time) / full_day_time_converted
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
