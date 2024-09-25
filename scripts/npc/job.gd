extends Landmark

class_name Job

@export var scheduler : Scheduler
## Expected amount of time this work expects its NPCs to stay.
## From 0 to 24.
@export var expected_work_time : float
## Ratio of how much of 'expected_work_time' is needed before reputation goes down
## From 0 to 1
@export var min_work_time_accepted : float
## The latest time an NPC would want to arrive at this job.
## From 0 to 24.
@export var time_want_to_arrive : float
@export var max_lateness : float
@export var max_worker_distance : float

func _ready() -> void:
	super()
	scheduler = get_tree().get_root().get_node("Main/Scheduler")
	radius_of_influence = max_worker_distance

func get_npc_want(npc : NPC, is_working_or_need_to_work : bool, interference : float) -> float:
	var time_want_to_arrive_corrected = (scheduler.full_day_time * time_want_to_arrive / 24.0) - time_to_arrive(npc)
	var lateness = scheduler.get_current_time() - time_want_to_arrive_corrected
	var lateness_weight = 0.0 if is_working_or_need_to_work else lateness * npc.personality.mind
	var time_weight : float

	var in_game_time_want_to_stop = (scheduler.full_day_time * (time_want_to_arrive + expected_work_time) / 24.0)
	if scheduler.get_current_time() > in_game_time_want_to_stop:
		var time_left = scheduler.time_left if scheduler.time_left > 0.0 else 0.1
		time_weight = -1 * in_game_time_want_to_stop / (time_left * sqrt(npc.personality.mind))
	elif scheduler.get_current_time() >= time_want_to_arrive_corrected:
		time_weight = scheduler.time_left / (sqrt(npc.personality.mind) * scheduler.full_day_time)
	else:
		time_weight = pow(npc.personality.soul, 2) * scheduler.get_current_time() / scheduler.full_day_time

	return super(npc, is_working_or_need_to_work, interference) + lateness_weight + time_weight

func save():
	var super_save = super()
	var save_dict = {
		"expected_work_time" : expected_work_time,
		"min_work_time_accepted" : min_work_time_accepted,
		"time_want_to_arrive" : time_want_to_arrive,
		"max_lateness" : max_lateness,
		"max_worker_distance" : max_worker_distance,
	}
	return super_save + save_dict

func get_in_game_expected_work() -> float:
	return scheduler.full_day_time * expected_work_time / 24.0

func has_worked_today(time_worked : float) -> bool:
	return time_worked >= (expected_work_time * scheduler.full_day_time / 24.0)
