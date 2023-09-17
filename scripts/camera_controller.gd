extends Node3D

@export_group("Rotation properties", "rotation_")
@export var rotation_speed:  float = 2.0
@export var rotation_angle:  float = 60.0

var is_rotating: bool = false
var target_rotation: float = 0.0

func _ready() -> void:
	self.rotation.y = 0.0

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("rotate_camera_clockwise"):
		target_rotation += deg_to_rad(rotation_angle)
	elif Input.is_action_just_pressed("rotate_camera_anticlockwise"):
		target_rotation -= deg_to_rad(rotation_angle)
		
	if not is_equal_approx(self.rotation.y, target_rotation):
		self.rotation.y = lerp_angle(self.rotation.y, target_rotation, delta * rotation_speed)
	else
		self.rotation.y = target_rotation
