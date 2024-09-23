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
	var lateness_weight = 0.0 if is_at_home else lateness * npc.personality.soul

	return super(npc, is_at_home, interference) + lateness_weight

#func _physics_process(_delta: float) -> void:
	#if not timer.is_stopped():
		#print("\n---- AT HOME ----")
		#print(timer.time_left)
		#print()
