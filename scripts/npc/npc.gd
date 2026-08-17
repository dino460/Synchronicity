extends Entity

class_name NPC

const base_move_speed     : float = 3.5
const base_run_multiplier : float = 2.67

signal idling
signal walking
signal death
signal running

var is_dead : bool = false
@onready var rigidbody_ref : RigidBody3D = $"."

@export_group("NPC Identity")
@export var npc_name : String
@export var id       : int
var process_group    : int

@export_group("NPC Scheduling")
@export var scheduler : Scheduler

@export_group("NPC Characteristics")
@export var current_age        : int
@export var cycles_to_next_age : int
@export var personality        : Personality

@export_group("NPC Navigation")
@export var navigation_agent : NavigationAgent3D
@export var max_stuck_time : float = 1.2
var stuck_timer : float = 0.0
var last_position : Vector3 = Vector3.ZERO

@export_group("NPC Movement")
var is_running     : bool = false
var look_direction : Vector3 = Vector3.ZERO
var velocity       : Vector3 = Vector3.ZERO

@export var minimum_movement_distance : float = 1.5

@export_group("NPC Rendering")
@onready var mesh_pivot_ref = $MeshPivot
@export var should_animate : bool = true
var viewport : Viewport

@export_group("NPC AI")
@export var home : Node3D
@export var gdpai_agent : GdPAIAgent
@export var label : Label


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

	scheduler = get_tree().get_root().get_node("Main/Scheduler")
	id = scheduler.request_id()
	process_group = scheduler.request_group()

	should_attack_move = true
	navigation_agent.debug_enabled = true

	viewport = get_viewport()

	call_deferred("late_setup")

func _physics_process(delta: float) -> void:
	if is_dead:
		return

	handle_navigation()

	if not navigation_agent.is_navigation_finished():
		look_direction = velocity.normalized()

		mesh_pivot_ref.rotation.y = \
			lerp_angle(
				mesh_pivot_ref.rotation.y,
				atan2(-look_direction.x,-look_direction.z),
				delta * 10.0
			)

	if should_animate:
		if not Vector2(velocity.x, velocity.z).is_zero_approx():
			if is_running:
				running.emit()
			else:
				walking.emit()
		else:
			idling.emit()

	self.global_position += velocity * delta

	if navigation_agent.is_navigation_finished():
		velocity = Vector3.ZERO

	if label != null and gdpai_agent != null:
		var energy: float = gdpai_agent.blackboard.get_property("energy")
		var goal_text: String
		if gdpai_agent._current_goal != null:
			goal_text = gdpai_agent._current_goal.get_title()

		var action_text: String
		if gdpai_agent._current_plan != null and gdpai_agent._current_plan.get_plan().size() > 0:
			var step: int = min(
				gdpai_agent._current_plan_step,
				gdpai_agent._current_plan.get_plan().size() - 1,
			)
			var action: Action = gdpai_agent._current_plan.get_plan()[step]
			action_text = action.get_title()
		label.text = (
			"Energy: %.f\nGoal: %s\nCurrent Action: %s" % [energy, goal_text, action_text]
		)

		var new_label_position = viewport.get_camera_3d().unproject_position(self.global_transform.origin)
		new_label_position *= viewport.get_parent().stretch_shrink
		new_label_position = Vector2(new_label_position.x - (label.size.x / 2.0) + 125, new_label_position.y - (label.size.y / 2.0))
		label.position = new_label_position

func handle_navigation():
	var desired_velocity = Vector3.ZERO

	var current_agent_position: Vector3 = self.global_position
	var next_path_position: Vector3 = navigation_agent.get_next_path_position()
	desired_velocity = current_agent_position.direction_to(next_path_position) * get_speed()
	desired_velocity.y = 0.0
	navigation_agent.velocity = desired_velocity
	# velocity = desired_velocity

func disable_pathfinding():
	navigation_agent.target_position = self.global_position
	velocity = Vector3.ZERO

# func do_attack(attack_state : AnimationHandler.AnimationState):
# 	super(attack_state)
# 	disable_pathfinding()
# 	var target_position : Vector3 = self.global_position + (-mesh_pivot_ref.global_basis.z * 100.0)
# 	handle_navigation(target_position, target_position, true)

func stop_attack_movement():
	super()
	disable_pathfinding()

func late_setup():
	if home != null: gdpai_agent.blackboard.set_property("home_position", home.position)


func _on_navigation_finished() -> void:
	velocity = Vector3.ZERO

func _on_trigger_death() -> void:
	print("NPC died")
	# _current_state = State.DEAD
	is_dead = true
	death.emit()

func _on_navigation_agent_3d_velocity_computed(safe_velocity:Vector3) -> void:
	velocity = safe_velocity
