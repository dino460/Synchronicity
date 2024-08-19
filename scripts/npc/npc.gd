extends CharacterBody3D

class_name NPC

const base_move_speed     : float = 4.0
const base_run_multiplier : float = 2.3
const base_acceleration   : float = 3.0

@export var job                : Job
@export var age                : int
@export var home               : Home
@export var points_of_interest : Array[Node3D]

@onready var navigation_agent: NavigationAgent3D = $NavigationAgent3D

var navigation_enabled : bool = false


func mod_by_age() -> float:
	return maxf(-sin(age / 31.85) * log(age / 100.0), 0.5)

func get_move_speed() -> float:
	return base_move_speed * mod_by_age()
	
func get_run_speed() -> float:
	return get_move_speed() * base_run_multiplier

func get_acceleration() -> float:
	return base_acceleration * mod_by_age()


func _ready():
	# Make sure to not await during _ready.
	call_deferred("actor_setup")

func actor_setup():
	navigation_agent.debug_enabled = true
	# Wait for the first physics frame so the NavigationServer can sync.
	await get_tree().physics_frame

	# Now that the navigation map is no longer empty, set the movement target.
	set_movement_target(home.location)

func set_movement_target(movement_target: Vector3):
	navigation_agent.set_target_position(movement_target)
	navigation_enabled = true

func _physics_process(delta):
	if navigation_agent.is_navigation_finished() && navigation_enabled:
		return

	var current_agent_position: Vector3 = global_position
	var next_path_position: Vector3 = navigation_agent.get_next_path_position()

	velocity = current_agent_position.direction_to(next_path_position) * get_move_speed()
	move_and_slide()
