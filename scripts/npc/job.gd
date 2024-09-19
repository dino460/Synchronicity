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
	var time_to_get_to_job = scheduler.full_day_time * time_want_to_arrive / 24.0
	var lateness = scheduler.get_current_time() - time_to_arrive(npc) + time_to_get_to_job
	var lateness_weight = lateness * (lateness * npc.personality.mind) if not is_at_job else 1.0
	print_rich("[color=yellow]%f[/color]" % lateness_weight)
	return super(npc, is_at_job) + lateness_weight

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
