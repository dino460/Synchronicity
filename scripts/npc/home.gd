extends Node3D

class_name Home

@export var timer : Timer
## Minimum percentage of time this home expects its NPCs to stay.
@export var home_time_min_proportion : float
## The latest time an NPC would want to arrive at this home.
## From 1 to 24.
@export var time_want_to_arrive_home : float
@export var is_at_home : bool = false

func _ready() -> void:
	timer = get_child(0)
	timer.one_shot = true

func _physics_process(_delta: float) -> void:
	if not timer.is_stopped():
		print("\n---- AT HOME ----")
		print(timer.time_left)
		print()
