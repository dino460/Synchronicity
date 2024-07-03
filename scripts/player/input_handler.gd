extends Node

class_name InputHandler

signal light_attack_performed
signal heavy_attack_performed
signal dash_performed


func _process(_delta):
	if Input.is_action_just_pressed("attack_light"):
		light_attack_performed.emit()

	elif Input.is_action_just_pressed("attack_heavy"):
		heavy_attack_performed.emit()

	elif Input.is_action_just_pressed("player_dash"):
		dash_performed.emit()


func get_player_direction_this_frame() -> Vector3:
	var new_direction : Vector3 = Vector3.ZERO
	
	new_direction.x = Input.get_axis("player_move_left", "player_move_right")
	new_direction.z = Input.get_axis("player_move_forward", "player_move_backward")
	
	return new_direction
