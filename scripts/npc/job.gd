extends Landmark

class_name Job

@export var scheduler : Scheduler
## Expected amount of time this work expects its NPCs to stay.
## From 0 to 24.
@export var expected_work_amount : float
## Ratio of how much of 'expected_work_amount' is needed before reputation goes down
## From 0 to 1
@export var min_work_accepted : float
## The latest time an NPC would want to arrive at this job.
## From 0 to 24.
@export var time_want_to_arrive : float
@export var max_late_amount : float
@export var max_worker_distance : float

func _ready() -> void:
	super()
	scheduler = get_tree().get_root().get_node("Main/Scheduler")

func get_npc_want(npc : NPC, is_at_job : bool) -> float:
	var time_want_to_arrive_corrected = scheduler.full_day_time * time_want_to_arrive / 24.0
	var lateness = scheduler.get_current_time() + time_to_arrive(npc) - time_want_to_arrive_corrected
	var lateness_weight = 1.0 if is_at_job else lateness * npc.personality.mind
	var time_weight : float

	var in_game_time_want_to_arrive = (scheduler.full_day_time * time_want_to_arrive / 24.0)
	var in_game_time_want_to_stop = (scheduler.full_day_time * (time_want_to_arrive + (expected_work_amount * min_work_accepted)) / 24.0)
	# scheduler.get_current_time() / (scheduler.full_day_time * time_want_to_arrive / 24.0)
	# print(scheduler.get_current_time())
	# print(in_game_time_want_to_stop)
	# print(in_game_time_want_to_arrive)
	# print(lateness)
	if scheduler.get_current_time() > in_game_time_want_to_stop:
		time_weight = in_game_time_want_to_arrive / (scheduler.get_current_time() * pow(npc.personality.mind, 2))
	elif scheduler.get_current_time() >= in_game_time_want_to_arrive:
		time_weight = scheduler.time_left / (sqrt(npc.personality.mind) * scheduler.full_day_time)
	else:
		print("---")
		time_weight = pow(npc.personality.soul, 2) * scheduler.get_current_time() / scheduler.full_day_time

	return super(npc, is_at_job) + lateness_weight + time_weight

func save():
	var super_save = super()
	var save_dict = {
		"expected_work_amount" : expected_work_amount,
		"min_work_accepted" : min_work_accepted,
		"time_want_to_arrive" : time_want_to_arrive,
		"max_late_amount" : max_late_amount,
		"max_worker_distance" : max_worker_distance,
	}
	return super_save + save_dict

func get_in_game_expected_work() -> float:
	return scheduler.full_day_time * expected_work_amount / 24.0
