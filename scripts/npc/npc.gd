extends Entity

class_name NPC

const base_move_speed     : float = 3.5
const base_run_multiplier : float = 2.67

signal idling
signal walking
signal death
signal running

var viewport : Viewport

var is_dead : bool = false
@onready var rigidbody_ref : RigidBody3D = $"."

@export var mesh : MeshInstance3D

@export_group("NPC Identity")
@export var npc_name : String
@export var id       : int
var process_group    : int

@export_group("NPC Scheduling")
# @export var timers    : Dictionary
@export var scheduler : Scheduler
@export var npc_brain : NPCBrain

@export_group("NPC Characteristics")
@export var current_age        : int
@export var cycles_to_next_age : int
@export var personality        : Personality

@export_group("NPC Landmarks")
@export var job                : Job
@export var home               : Home
@export var visits             : Dictionary
@export var points_of_interest : Array[Landmark]

@export_group("NPC Navigation")
@onready var navigation_agent : NavigationAgent3D = $NavigationAgent3D
@export var max_stuck_time : float = 1.2
var stuck_timer : float = 0.0
var last_position : Vector3 = Vector3.ZERO

@export_group("NPC Movement")
var is_running         : bool = false
var look_direction     : Vector3 = Vector3.ZERO
var look_target        : Vector3 = Vector3.ZERO
var velocity           : Vector3 = Vector3.ZERO

var off_screen_movement_update_timer : float = 0.0
@export var off_screen_movement_update_rate : float = 1.0
# var navigation_enabled : bool = false
@export var minimum_movement_distance : float = 1.5

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

	viewport = get_viewport()

	# weapon_attatchment = $"MeshPivot/Low-Poly-Base_blend/rig/Skeleton3D/BoneAttachment3D"

	should_attack_move = true
	navigation_agent.debug_enabled = true


func _process(delta: float) -> void:
	if not navigation_agent.is_navigation_finished() and last_position.distance_squared_to(self.global_position) <= last_position.distance_squared_to(last_position + (-mesh_pivot_ref.global_basis.z * get_speed() * delta)):
		stuck_timer += delta
		if stuck_timer >= max_stuck_time:
			npc_brain.reset_brain()
			stuck_timer = 0.0
	else:
		stuck_timer = 0.0

	last_position = self.global_position

	off_screen_movement_update_timer += delta

func _physics_process(delta: float) -> void:
	if is_dead:
		return

	if not navigation_agent.is_navigation_finished():
		if look_target < Vector3.INF:
			look_direction = self.global_position.direction_to(look_target)
		else:
			look_direction = velocity.normalized()
		mesh_pivot_ref.rotation.y = lerp_angle(mesh_pivot_ref.rotation.y, atan2(-look_direction.x, -look_direction.z), delta * 10.0)

	if should_animate:
		if not Vector2(velocity.x, velocity.z).is_zero_approx():
			if is_running:
				running.emit()
			else:
				walking.emit()
		else:
			idling.emit()

	global_position += velocity * delta

	if navigation_agent.is_navigation_finished():
		velocity = Vector3.ZERO

func handle_navigation(target_position : Vector3, look_target_position : Vector3, run : bool):
	var desired_velocity = Vector3.ZERO

	if should_attack_move == false or is_dead:
		return

	look_target = look_target_position

	if target_position.distance_to(self.global_position) < minimum_movement_distance:
		look_direction = self.global_position.direction_to(target_position)
		navigation_agent.target_position = self.global_position
		return

	navigation_agent.target_position = target_position

	is_running = run

	var current_agent_position: Vector3 = global_position
	var next_path_position: Vector3 = navigation_agent.get_next_path_position()
	desired_velocity = current_agent_position.direction_to(next_path_position) * get_speed()
	# desired_velocity.y = -75.0
	navigation_agent.velocity = desired_velocity

func disable_pathfinding():
	navigation_agent.target_position = self.global_position
	velocity = Vector3.ZERO

func do_attack(attack_state : AnimationHandler.AnimationState):
	super(attack_state)
	disable_pathfinding()
	var target_position : Vector3 = self.global_position + (-mesh_pivot_ref.global_basis.z * 100.0)
	handle_navigation(target_position, target_position, true)

func stop_attack_movement():
	super()
	disable_pathfinding()


func _on_navigation_finished() -> void:
	npc_brain.arrive_at_landmark_target()
	velocity = Vector3.ZERO

func _on_trigger_death() -> void:
	print("NPC died")
	# _current_state = State.DEAD
	is_dead = true
	death.emit()

func _on_navigation_agent_3d_velocity_computed(safe_velocity:Vector3) -> void:
	velocity = safe_velocity

func _on_visible_on_screen_enabler_3d_screen_exited() -> void:
	# if update_again:
	# 	should_animate = false
	# 	self.visible = false
	# print("exited")
	pass

func _on_visible_on_screen_enabler_3d_screen_entered() -> void:
	# if update_again:
	# 	should_animate = true
	# 	self.visible = true
	# print("entered")
	pass
