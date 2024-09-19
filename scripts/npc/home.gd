extends Landmark

class_name Home

## Minimum amount of time this home expects its NPCs to stay.
## From 0 to 24.
@export var min_home_amount : float
## The latest time an NPC would want to arrive at this home.
## From 1 to 24.
@export var time_want_to_arrive_home : float
@export var max_late_amount : float

func _ready() -> void:
	super()


#func _physics_process(_delta: float) -> void:
	#if not timer.is_stopped():
		#print("\n---- AT HOME ----")
		#print(timer.time_left)
		#print()
