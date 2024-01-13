extends CharacterBody3D

# Get references to nodes
# Removes get_node call each time the node is referenced 
@onready var dash_timer_ref = $DashTimer
@onready var mesh_pivot_ref = $MeshPivot
@onready var camera_pivot_ref = $CameraPivot

signal idling
signal walking
signal running
signal dashing(dash_time)

@export_group("Movement Properties")
@export var applied_speed : float = 0.0
@export var walk_speed    : float = 3.3

@export var run_speed     : float = 18.0
@export var run_is_toggle : bool  = false

@export var dash_speed : float = 32.0
@export var dash_time  : float = 0.2
@export var is_dashing : bool  = false

@export var fall_acceleration : float = 75.0


@export_group("Rotation Properties")
@export var smooth_speed : float = 2.0

var target_velocity : Vector3 = Vector3.ZERO
var direction       : Vector3 = Vector3.ZERO


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta : float) -> void:
	if Input.is_action_just_pressed("player_dash") and not is_dashing and not direction == Vector3.ZERO:
		is_dashing = true
		applied_speed = dash_speed
		dashing.emit(dash_time)
	
	if not is_dashing:
		if run_is_toggle:
			if Input.is_action_just_pressed("player_run"):
				if applied_speed != run_speed:
					applied_speed = run_speed
				else:
					applied_speed = walk_speed
		else:
			if (Input.is_action_pressed("player_run")):
				applied_speed = run_speed
			else:
				applied_speed = walk_speed


func _physics_process(delta : float) -> void:
	direction = get_player_direction_this_frame()
	
	if direction != Vector3.ZERO:
		if not is_dashing:
			if applied_speed == run_speed:
				running.emit()
			else:
				walking.emit()
			
		# Rotates direction of movement around UP axis in relation to camera and then normalizes it
		direction = rotate_direction(direction)
		# Smoothly rotate character Mesh3D to face direction of movement
		mesh_pivot_ref.rotation.y = lerp_angle(mesh_pivot_ref.rotation.y, atan2(-direction.x, -direction.z), delta * smooth_speed)
	else:
		idling.emit()
	
	target_velocity.x = direction.x * applied_speed
	target_velocity.z = direction.z * applied_speed
	
	# Something is making player bump
	# Disabling gravity makes it work
	if not is_on_floor():
		target_velocity.y = target_velocity.y - (fall_acceleration * delta)
	else:
		target_velocity.y = 0.0
	
	velocity = target_velocity
	move_and_slide()


func get_player_direction_this_frame() -> Vector3:
	var new_direction : Vector3 = Vector3.ZERO
	
	new_direction.x = Input.get_axis("player_move_left", "player_move_right")
	new_direction.z = Input.get_axis("player_move_forward", "player_move_backward")
	
	return new_direction

func rotate_direction(direction_to_rotate : Vector3) -> Vector3:
	return direction_to_rotate.rotated(Vector3.UP, camera_pivot_ref.global_transform.basis.get_euler().y).normalized()



func _on_animation_handler_dash_ended():
	is_dashing = false
