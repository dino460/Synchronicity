extends Timer

class_name Scheduler

@export var full_day_time : float = 600.0
@export var sun_up_time : float
@export var sun_down_time : float

@export var is_sun_up : bool = false
@export var sun : DirectionalLight3D

@export var npc_holder : Node
@export var clock_label : Label

@export var next_available_id : int = 1

@export var number_of_groups : int = 10
var process_groups = []
var thread_group : Array[Thread] = []
var current_group : int = 0

var frame_counter : int


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
		thread_group[i].start(run_process_group.bind(i, thread))

	print_rich("[color=yellow][b] DAY START [/b][/color]")
	start()

func _process(_delta: float) -> void:
	is_sun_up = true if get_current_time() >= (sun_up_time * full_day_time / 24.0) and get_current_time() < (sun_down_time * full_day_time / 24.0) else false

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
	if not thread_group[frame_counter].is_alive():
		var thread = Thread.new()
		thread_group[frame_counter] = thread
		thread_group[frame_counter].start(run_process_group.bind(frame_counter, thread_group[frame_counter]))

	frame_counter += 1
	if frame_counter >= number_of_groups:
		frame_counter = 0

func rotate_sun():
	if sun != null:
		var sun_x_rotation : float
		var light_time = (sun_down_time - sun_up_time) * full_day_time / 24.0
		sun_x_rotation = ((-get_current_time() + (sun_up_time * full_day_time / 24.0)) / (2 * light_time)) * 360.0

		sun.rotation_degrees = Vector3(
			# ((time_left + (full_day_time / 3.0)) / full_day_time) * 360.0,
			sun_x_rotation,
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

func run_process_group(group : int, thread : Thread):
	for process in process_groups[group]:
		process.call_deferred()
	call_deferred("wait_thread", thread)

func wait_thread(thread : Thread):
	thread.wait_to_finish()

func restart_thread(thread_num : int):
	thread_group[thread_num].wait_to_finish()
	var thread = Thread.new()
	thread_group[thread_num] = thread
	thread_group[thread_num].start(run_process_group.bind(thread_num))

func _exit_tree() -> void:
	for thread in thread_group:
		thread.wait_to_finish()
