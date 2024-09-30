extends Timer

class_name Scheduler

@export var full_day_time : float = 600.0
@export var sun_up_time_proportion : float = 0.5

@export var is_sun_up : bool = false
@export var sun : DirectionalLight3D

@export var npc_holder : Node
@export var clock_label : Label

@export var next_available_id : int = 1

var process_groups = []
var thread_group : Array[Thread] = []
var number_of_groups : int = 5
var current_group : int = 0


func _ready() -> void:
	add_to_group("persist")
	is_sun_up = true
	wait_time = full_day_time
	one_shot = true
	process_groups.resize(number_of_groups)
	thread_group.resize(number_of_groups)
	for i in number_of_groups:
		var arr : Array[Callable]
		var thread = Thread.new()
		process_groups[i] = arr
		thread_group[i] = thread
		thread_group[i].start(run_process_group.bind(i))

	print_rich("[color=yellow][b] DAY START [/b][/color]")
	start()

func _process(_delta: float) -> void:
	is_sun_up = false if time_left <= (full_day_time * sun_up_time_proportion) else true
	var hours : int = get_current_time() * 24 / full_day_time
	var minutes : int = ((get_current_time() * 24 / full_day_time) - hours) * 60
	if clock_label != null:
		clock_label.text = "%d:%d | %f | %d" % [hours, minutes, get_current_time(), Engine.get_frames_per_second()]

	rotate_sun()

	if is_stopped():
		print_rich("[color=red][b] DAY OVER [/b][/color]")
		for npc in npc_holder.get_children():
			npc.reset_has_worked_today()

		start()

func _physics_process(_delta: float) -> void:
	for i in number_of_groups:
		if not thread_group[i].is_alive():
			var thread = Thread.new()
			thread.start(restart_thread.bind(i))
	current_group += 1

	if current_group >= number_of_groups:
		current_group = 0

func rotate_sun():
	if sun != null:
		sun.rotation_degrees = Vector3(
			((time_left + (full_day_time / 3.0)) / full_day_time) * 360.0,
			sun.rotation_degrees.y,
			sun.rotation_degrees.z
		)

func get_current_time() -> float:
	return full_day_time - time_left

func get_current_time_24() -> String:
	var hours : int = get_current_time() * 24 / full_day_time
	var minutes : int = ((get_current_time() * 24 / full_day_time) - hours) * 60

	return "%d:%d" % [hours, minutes]

func request_id() -> int:
	var id = next_available_id
	next_available_id += 1

	return id

func request_group() -> int:
	return randi_range(0, number_of_groups - 1)

func bind_callable_to_group(group : int, callable : Callable):
	process_groups[group].push_back(callable)

func run_process_group(group : int):
	for process in process_groups[group]:
		process.call_deferred()

func restart_thread(thread_num : int):
	thread_group[thread_num].wait_to_finish()
	var thread = Thread.new()
	thread_group[thread_num] = thread
	thread_group[thread_num].start(run_process_group.bind(thread_num))

func _exit_tree() -> void:
	for thread in thread_group:
		thread.wait_to_finish()
