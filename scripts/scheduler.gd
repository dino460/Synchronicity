extends Node

class_name Scheduler

signal day_start
signal day_over

@export_group("Cycle Parameters")
var time : float
var cycle_total_time : float

@export var day_total_time   : float = 80.0
@export var night_total_time : float = 60.0

## Time in seconds from the start of the cycle that the scheduler should start.
## Conversion from hours should be (TIME - 6) * cycle_total_time / 24
@export var start_time : float = 0.0

@export var time_warp_mod : float = 1.0

@export var is_day : bool = false
@export var is_time_paused : bool = false

@export_group("Sun Parameters")
@export var sun : DirectionalLight3D

@export var sun_rotation : Curve
@export var sun_energy   : Curve
@export var sun_color    : Gradient

@export_group("Environment Parameters")
@export var environment : WorldEnvironment

@export var environment_energy   : Curve
@export var environment_color    : Gradient

@export_group("NPC Threading Parameters")
@export var npc_holder : Node
@export var clock_label : Label

@export var next_available_id : int = 0

@export var player_ref : Node3D
@export var camera_ref : Camera3D


func _ready() -> void:
	add_to_group("persist")

	cycle_total_time = day_total_time + night_total_time

	is_day = true
	update_sun_and_environment(0.0)
	time = start_time
	if start_time >= day_total_time:
		is_day = false
		start_time -= day_total_time

	camera_ref = player_ref.get_node("CameraPivot/EnvironmentCamera3D/FrustumCulllingCamera3D")


func _process(delta: float) -> void:
	if Input.is_action_just_pressed("test_action"):
		is_time_paused = not is_time_paused
		time_warp_mod = 1.0

	var hours : int = fmod(6 + get_current_time() * 24 / cycle_total_time, 24.0)
	var minutes : int = (fmod(6 + get_current_time() * 24 / cycle_total_time, 24.0) - hours) * 60
	if clock_label != null:
		clock_label.text = "%d:%d | %f | %d" % [hours, minutes, get_current_time(), Engine.get_frames_per_second()]

	var total_time = day_total_time if is_day else night_total_time
	update_sun_and_environment(time)
	if not is_time_paused:
		time += delta / total_time
	elif Input.is_action_pressed("reverse_time"):
		time -= delta * time_warp_mod / total_time
	elif Input.is_action_pressed("forward_time"):
		time += delta * time_warp_mod / total_time

	if Input.is_action_just_pressed("increase_time_warp"):
		time_warp_mod *= 2.0
	elif Input.is_action_just_pressed("decrease_time_warp"):
		time_warp_mod /= 2.0

	if time > 1.0:
		time = 0.0
		if is_day: day_over.emit()
		else: day_start.emit()
		is_day = not is_day
	elif time < 0.0:
		time = 0.999999
		if is_day: day_over.emit()
		else: day_start.emit()
		is_day = not is_day


func _physics_process(_delta: float) -> void:
	call_deferred("stop_npc_animation")


func stop_npc_animation():
	for npc in npc_holder.get_children():
		npc.should_animate = camera_ref.is_position_in_frustum(npc.position)

func update_sun_and_environment(sample_point : float):
	if sun != null and is_day:
		sun.rotation.x = deg_to_rad(sun_rotation.sample(sample_point))
		sun.light_energy = sun_energy.sample(sample_point)
		sun.light_color = sun_color.sample(sample_point)
	if environment != null and is_day:
		environment.environment.ambient_light_energy = environment_energy.sample(sample_point)
		environment.environment.ambient_light_color = environment_color.sample(sample_point)

func get_current_time() -> float:
	return time * day_total_time if is_day else time * night_total_time + day_total_time

func get_current_time_24() -> String:
	var hours : int = get_current_time() * 24 / cycle_total_time
	var minutes : int = ((get_current_time() * 24 / cycle_total_time) - hours) * 60

	return "%d:%d" % [hours, minutes]

func request_id() -> int:
	var id = next_available_id
	next_available_id += 1

	return id
