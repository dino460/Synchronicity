extends Node3D

@export_group("Rotation properties", "rotation_")
@export var rotation_speed :  float = 2.0
@export var rotation_angle :  float = 60.0

@export_group("Vertical properties", "vertical_")
@export var vertical_speed          :  float = 2.0
@export var vertical_base_target    :  float = 6.0
@export var vertical_up_corretion   :  float = 0.75
@export var vertical_down_corretion : float = 0.25


@onready var mesh_pivot_ref : Node3D = $"../MeshPivot"
@onready var orthogonal_camera_ref = $"Camera3D - Orthogonal"

var is_rotating : bool = false
var target_rotation : float = 0.0

var vertical_target : float = 0.0


func _ready() -> void:
	self.rotation.y = 0.0

func _process(delta: float) -> void:
	update_target_rotation()
	
	if not is_equal_approx(self.rotation.y, target_rotation):
		self.rotation.y = lerp_angle(self.rotation.y, target_rotation, delta * rotation_speed)
	else:
		self.rotation.y = target_rotation
	
	if not is_equal_approx(orthogonal_camera_ref.position.y, vertical_target):
		orthogonal_camera_ref.position.y = lerpf(orthogonal_camera_ref.position.y, vertical_target, delta * vertical_speed)
	else:
		orthogonal_camera_ref.position.y = vertical_target

func _physics_process(delta: float) -> void:
	update_vertical_target()
	pass

func update_target_rotation():
	if Input.is_action_just_pressed("rotate_camera_left"):
		target_rotation += deg_to_rad(rotation_angle)
	elif Input.is_action_just_pressed("rotate_camera_right"):
		target_rotation -= deg_to_rad(rotation_angle)

func update_vertical_target():
	var mesh_forward = Vector3(mesh_pivot_ref.transform.basis.z)
	var this_forward = Vector3(self.transform.basis.z)
	
	print(mesh_forward.angle_to(this_forward), " ", mesh_forward, " ", this_forward)
	
	if mesh_forward.angle_to(this_forward) < 0.8:
		vertical_target = vertical_base_target + vertical_up_corretion
	elif mesh_forward.angle_to(this_forward) > 2.3:
		vertical_target = vertical_base_target - vertical_down_corretion
	else:
		vertical_target = vertical_base_target
