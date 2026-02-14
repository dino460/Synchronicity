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

func is_home() -> bool:
	return true
