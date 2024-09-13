extends Timer

class_name Scheduler

@export var full_day_time : float = 600.0
@export var sun_up_time_proportion : float = 0.5

@export var is_sun_up : bool = false

@export var sun : DirectionalLight3D

@export var npc_holder : Node
var npc_list : Array[NPC]


func _ready() -> void:
	for npc in npc_holder.get_children():
		npc_list.append(npc.get_script())

	is_sun_up = true
	wait_time = full_day_time
	start()

func _process(_delta: float) -> void:
	is_sun_up = false if time_left <= (full_day_time * sun_up_time_proportion) else true

	rotate_sun()

	if is_stopped():
		for npc in npc_list:
			npc.reset_has_worked_today()

		start()

# func _physics_process(_delta: float) -> void:
# 	print("TIME: ", get_current_time() * 24 / full_day_time)
# 	print("TIME LEFT: ", time_left * 24 / full_day_time)
# 	print()

func rotate_sun():
	if sun != null:
		sun.rotation_degrees = Vector3(
			(time_left / full_day_time) * 360.0,
			sun.rotation_degrees.y,
			sun.rotation_degrees.z
		)

func get_current_time() -> float:
	return full_day_time - time_left
