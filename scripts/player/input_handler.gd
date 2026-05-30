extends Node

class_name InputHandler

signal up_attack_performed
signal down_attack_performed
signal left_attack_performed
signal right_attack_performed
signal dash_performed
signal toggle_attack_mode
signal stance(stance_val : int)
signal increase_stance
signal decrease_stance


func _physics_process(_delta: float) -> void:
	if Input.is_action_just_pressed("attack_up"):
		up_attack_performed.emit()
	elif Input.is_action_just_pressed("attack_down"):
		down_attack_performed.emit()
	elif Input.is_action_just_pressed("attack_left"):
		left_attack_performed.emit()
	elif Input.is_action_just_pressed("attack_right"):
		right_attack_performed.emit()
	elif Input.is_action_just_pressed("player_dash"):
		dash_performed.emit()

	if Input.is_action_just_pressed("stance_null"):
		stance.emit(0)
	elif Input.is_action_just_pressed("stance_1"):
		stance.emit(1)
	elif Input.is_action_just_pressed("stance_2"):
		stance.emit(2)
	elif Input.is_action_just_pressed("stance_3"):
		stance.emit(3)
	elif Input.is_action_just_pressed("stance_4"):
		stance.emit(4)
	elif Input.is_action_just_pressed("next_stance"):
		increase_stance.emit()
	elif Input.is_action_just_pressed("previous_stance"):
		decrease_stance.emit()


func get_player_direction_this_frame() -> Vector3:
	var new_direction : Vector3 = Vector3.ZERO

	new_direction.x = Input.get_axis("player_move_left", "player_move_right")
	new_direction.z = Input.get_axis("player_move_forward", "player_move_backward")

	return new_direction
