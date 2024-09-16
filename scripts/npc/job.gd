extends Node3D

class_name Job

@export var timer : Timer
## Expected amount of time this work expects its NPCs to stay.
## From 0 to 24.
@export var expected_work_amount : float
## Ratio of how much of 'expected_work_amount' is needed before reputation goes down
## From 0 to 1
@export var min_work_accepted : float
## The latest time an NPC would want to arrive at this job.
## From 0 to 24.
@export var time_want_to_arrive_job : float
@export var max_late_amount : float
@export var max_worker_distance : float
@export var is_at_job : bool = false

@export var reputations : Array[Reputation]

func _ready() -> void:
	timer = get_child(0)
	timer.one_shot = true

#func _physics_process(_delta: float) -> void:
	#if not timer.is_stopped():
		#print("\n---- AT JOB ----")
		#print(timer.time_left)
		#print()
