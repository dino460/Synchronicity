extends CharacterBody3D

@export_group("Movement Properties")
@export var speed: float = 14.0
@export var fall_acceleration: float = 75.0

@export_group("Rotation Properties")
@export var smooth_speed = 2.0


var target_velocity: Vector3 = Vector3.ZERO


func _physics_process(delta: float) -> void:
	var direction: Vector3 = Vector3.ZERO

	direction.x = Input.get_axis("player_move_left", "player_move_right")
	direction.z = Input.get_axis("player_move_forward", "player_move_backward")
	
	if direction != Vector3.ZERO:
		# Rotates direction around UP axis in relation to camera and then normalizes it
		direction = direction.rotated(Vector3.UP, $CameraPivot.global_transform.basis.get_euler().y).normalized()
		# Smoothly rotate character Mesh3D to face direction of movement
		$MeshPivot.rotation.y = lerp_angle($MeshPivot.rotation.y, atan2(-direction.x, -direction.z), delta * smooth_speed)
	
	target_velocity.x = direction.x * speed
	target_velocity.z = direction.z * speed
	
	if not is_on_floor():
		target_velocity.y = target_velocity.y - (fall_acceleration * delta)
	
	velocity = target_velocity
	move_and_slide()
