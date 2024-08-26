extends Node3D

class_name Job

@export var timer : Timer
## Minimum percentage of time this work expects its NPCs to stay.
@export var job_time_min_proportion : float
## The latest time an NPC would want to arrive at this job.
## From 1 to 24.
@export var time_want_to_arrive_job : float
@export var is_at_job : bool = false

func _ready() -> void:
	timer = get_child(0)
	timer.one_shot = true

func _physics_process(_delta: float) -> void:
	if not timer.is_stopped():
		print("\n---- AT JOB ----")
		print(timer.time_left)
		print()
