extends CharacterBody3D

@export_group("Movement Properties")
@export var speed      : float = 0.0
@export var walk_speed : float = 10.0

@export var run_speed     : float = 16.0
@export var run_is_toggle : bool  = false

@export var dash_speed : float = 32.0
@export var dash_time  : float = 0.2
@export var is_dashing : bool  = false

@export var fall_acceleration : float = 75.0


@export_group("Rotation Properties")
@export var smooth_speed : float = 2.0

var target_velocity : Vector3 = Vector3.ZERO
var direction       : Vector3 = Vector3.ZERO


func _process(_delta : float) -> void:
	if Input.is_action_just_pressed("player_dash") and not is_dashing:
		is_dashing = true
		speed = dash_speed
		$DashTimer.wait_time = dash_time
		$DashTimer.start()
	
	if $DashTimer.is_stopped():
		is_dashing = false
	
	if not is_dashing:
		if run_is_toggle:
			if Input.is_action_just_pressed("player_run"):
				speed = run_speed if speed != run_speed else walk_speed
		else:
			speed = run_speed if Input.is_action_pressed("player_run") else walk_speed


func _physics_process(delta : float) -> void:
	direction = get_player_direction_this_frame()
	
	if direction != Vector3.ZERO:
		# Rotates direction around UP axis in relation to camera and then normalizes it
		direction = rotate_direction(direction)
		# Smoothly rotate character Mesh3D to face direction of movement
		$MeshPivot.rotation.y = lerp_angle($MeshPivot.rotation.y, atan2(-direction.x, -direction.z), delta * smooth_speed)
	
	target_velocity.x = direction.x * speed
	target_velocity.z = direction.z * speed
	
	if not is_on_floor():
		target_velocity.y = target_velocity.y - (fall_acceleration * delta)
	
	velocity = target_velocity
	move_and_slide()


func get_player_direction_this_frame() -> Vector3:
	var new_direction : Vector3 = Vector3.ZERO
	
	new_direction.x = Input.get_axis("player_move_left", "player_move_right")
	new_direction.z = Input.get_axis("player_move_forward", "player_move_backward")
	
	return new_direction

func rotate_direction(direction_to_rotate : Vector3) -> Vector3:
	return direction_to_rotate.rotated(Vector3.UP, $CameraPivot.global_transform.basis.get_euler().y).normalized()
