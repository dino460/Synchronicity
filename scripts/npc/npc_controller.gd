extends Entity

class_name NPCController

const base_move_speed     : float = 3.5
const base_run_multiplier : float = 2.67

signal idling
signal walking
signal death
signal running

signal request_new_position(position : Vector3, forward : Vector3)
signal append_landmark(landmark : Landmark, landmark_position : Vector3)

var is_dead : bool = false
@onready var rigidbody_ref : RigidBody3D = $"."

@export var mesh : MeshInstance3D

@export_group("NPC Identity")
@export var npc_name : String
@export var id       : int
var process_group    : int

@export_group("NPC States")
var current_state : NPCState
var states : Array[NPCState]

@export_group("NPC Scheduling")
@export var scheduler : Scheduler
var state_run_output : Dictionary = {}
# var helper_thread : Thread

# var timer_control : bool = false
var timer : Timer

@export_group("NPC Characteristics")
@export var current_age        : int
@export var cycles_to_next_age : int
@export var personality        : Personality

@export_group("NPC Navigation")
@onready var navigation_agent : NavigationAgent3D = $NavigationAgent3D

@export_group("NPC Movement")
var is_running     : bool = false
var look_direction : Vector3 = Vector3.ZERO
var final_velocity : Vector3 = Vector3.ZERO

@export_group("NPC Rendering")
@onready var mesh_pivot_ref = $MeshPivot
@export var should_animate : bool = true


func mod_by_age() -> float:
	return minf(maxf((-sin(current_age / 31.85) * log(current_age / 100.0)) + 0.05, 0.5), 1.0)

func get_walk_speed() -> float:
	return base_move_speed * mod_by_age()

func get_run_speed() -> float:
	return get_walk_speed() * base_run_multiplier

func get_speed() -> float:
	return get_run_speed() if is_running else get_walk_speed()


func _ready() -> void:
	add_to_group("persist")

	get_node("AnimationHandler").caller_prefix = ""
	get_node("AnimationHandler").connect("attack_ended", _on_animation_handler_attack_ended)

	personality = get_node("Personality")
	scheduler = get_tree().get_root().get_node("Main/Scheduler")
	id = scheduler.request_id()
	process_group = scheduler.request_group()

	should_animate = false
	should_attack_move = true
	navigation_agent.debug_enabled = true

	var idle = IdleState.new()
	idle.personality = self.personality
	idle.this_npc_id = self.id
	states.append(idle)
	current_state = states[0]
	idle.connect("send_position", _receive_position)
	idle.connect("send_timer", _receive_timer)
	self.connect("request_new_position", idle._on_position_request)
	self.connect("append_landmark", idle._on_append_landmark)
	add_child(idle)

	# helper_thread = Thread.new()
	timer = Timer.new()
	add_child(timer)
	timer.connect("timeout", _on_timer_timeout)
	# scheduler.call_deferred("bind_callable_to_group", process_group, run)


func _process(_delta: float) -> void:
	pass

func _physics_process(delta: float) -> void:
	if is_dead:
		return

	if should_animate:
		if not Vector2(final_velocity.x, final_velocity.z).is_zero_approx():
			if is_running:
				running.emit()
			else:
				walking.emit()
		else:
			idling.emit()

	if navigation_agent.is_navigation_finished() and timer.is_stopped():
		request_new_position.emit(self.global_position, -self.mesh_pivot_ref.global_transform.basis.z)
	elif not look_direction.is_zero_approx():
		mesh_pivot_ref.rotation.y = lerp_angle(mesh_pivot_ref.rotation.y, atan2(-look_direction.x, -look_direction.z), delta * 10.0)

	look_direction = final_velocity.normalized()

	var desired_velocity = global_position.direction_to(navigation_agent.get_next_path_position()) * get_speed()
	navigation_agent.velocity = desired_velocity

	global_position += final_velocity * delta
	state_run_output = {}


# func run(npc_position : Vector3, forward : Vector3):
# 	state_run_output = current_state.run(npc_position, forward, timer_control)

# func wait_thread(thread : Thread):
# 	thread.wait_to_finish()


func reset_pathfinding():
	navigation_agent.target_position = self.global_position
	final_velocity = Vector3.ZERO

func _append_landmark(landmark : Landmark, landmark_position : Vector3):
	append_landmark.emit(landmark, landmark_position)

# func _on_timer_timeout():
# 	timer_control = false
# 	pass

func _receive_position(target_position : Vector3):
	navigation_agent.target_position = target_position

func _receive_timer(wait_time : float):
	reset_pathfinding()
	timer.wait_time = wait_time
	timer.start()

func _on_timer_timeout():
	timer.stop()

func _on_navigation_finished() -> void:
	final_velocity = Vector3.ZERO

func _on_trigger_death() -> void:
	print("NPC died")
	# _current_state = State.DEAD
	is_dead = true
	death.emit()

func _on_navigation_agent_3d_velocity_computed(safe_velocity:Vector3) -> void:
	final_velocity = safe_velocity
