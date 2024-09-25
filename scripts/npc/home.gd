extends Landmark

class_name Home

@export var scheduler : Scheduler
## Minimum amount of time this home expects its NPCs to stay.
## From 0 to 24.
@export var expected_home_time : float
## The latest time an NPC would want to arrive at this home.
## From 1 to 24.
@export var time_want_to_arrive : float
@export var max_lateness : float

func _ready() -> void:
	super()
	scheduler = get_tree().get_root().get_node("Main/Scheduler")

func get_npc_want(npc : NPC, is_at_home : bool, interference : float) -> float:
	var time_want_to_arrive_corrected = (scheduler.full_day_time * time_want_to_arrive / 24.0) - time_to_arrive(npc)
	var lateness = scheduler.get_current_time() - time_want_to_arrive_corrected
	var lateness_weight = 0.0
	if not is_at_home:
		lateness_weight = lateness * npc.personality.mind / npc.personality.soul
	if lateness_weight < -1.0:
		lateness_weight = 0.0

	var time_can_leave = time_want_to_arrive + expected_home_time
	var leave_weight = 0.0

	if time_can_leave > 23.999:
		time_can_leave -= 24.0

		if ((scheduler.get_current_time() >= expected_home_time and scheduler.get_current_time() >= time_can_leave) or
			(scheduler.get_current_time() <= expected_home_time and scheduler.get_current_time() <= time_can_leave)):
			leave_weight = -(get_npc_reputation(npc.id) * npc.personality.aggression / npc.personality.loyalty)
		else:
			leave_weight = scheduler.get_current_time() * npc.personality.loyalty / (time_want_to_arrive * get_npc_reputation(npc.id) * npc.personality.aggression)
	elif scheduler.get_current_time() >= expected_home_time and scheduler.get_current_time() <= time_can_leave:
		leave_weight = -(get_npc_reputation(npc.id) * npc.personality.aggression / npc.personality.loyalty)
	else:
		leave_weight = scheduler.get_current_time() * npc.personality.loyalty / (time_want_to_arrive * get_npc_reputation(npc.id) * npc.personality.aggression)

	return super(npc, is_at_home, interference) + lateness_weight - leave_weight

#func _physics_process(_delta: float) -> void:
	#if not timer.is_stopped():
		#print("\n---- AT HOME ----")
		#print(timer.time_left)
		#print()
