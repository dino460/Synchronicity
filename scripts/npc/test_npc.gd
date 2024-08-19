extends CharacterBody3D

@export var movement_speed: float = 4.0
@export var movement_targets: Array[Node3D]

var current_index : int = 0
var first_iteration : bool = true

@onready var navigation_agent: NavigationAgent3D = $NavigationAgent3D

func _ready():
	# Make sure to not await during _ready.
	call_deferred("actor_setup")

func actor_setup():
	navigation_agent.debug_enabled = true
	# Wait for the first physics frame so the NavigationServer can sync.
	await get_tree().physics_frame

	# Now that the navigation map is no longer empty, set the movement target.
	set_movement_target(movement_targets[current_index].position)

func set_movement_target(movement_target: Vector3):
	first_iteration = false
	navigation_agent.set_target_position(movement_target)

func _physics_process(delta):
	if navigation_agent.is_navigation_finished() and not first_iteration:
		current_index += 1
		if current_index >= movement_targets.size():
			current_index = 0
			
		set_movement_target(movement_targets[current_index].position)
		return

	var current_agent_position: Vector3 = global_position
	var next_path_position: Vector3 = navigation_agent.get_next_path_position()

	velocity = current_agent_position.direction_to(next_path_position) * movement_speed
	move_and_slide()
