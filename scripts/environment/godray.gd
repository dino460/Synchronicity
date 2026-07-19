extends MultiMeshInstance3D

class_name Godray

@export var camera : Camera3D
@export var directional_light : DirectionalLight3D

var number_of_meshes : int
var spawn_area_size : float
var spawn_area_center : Vector3
var godray_mesh : MeshInstance3D
var scheduler : Scheduler

func _ready():
	scheduler.day_start.connect(_on_day_start)
	scheduler.day_over.connect(_on_day_over)
	multimesh.use_custom_data = true
	multimesh.transform_format = MultiMesh.TRANSFORM_3D
	multimesh.instance_count = number_of_meshes
	multimesh.visible_instance_count = number_of_meshes
	multimesh.mesh = godray_mesh.mesh
	# In godray.gd _ready(), after setting up the multimesh:
	# Set a large enough AABB that no instance gets culled while its geometry is visible.
	# The AABB is in local space of the MultiMeshInstance3D, centered at origin.
	var half = 40.0  # or larger if quad_size can change at runtime
	multimesh.custom_aabb = AABB(Vector3(-half, -half, -half), Vector3(half, half, half) * 2.0)

	camera = get_viewport().get_camera_3d()
	directional_light = get_viewport().find_child("DirectionalLight3D")

	for i in multimesh.visible_instance_count:
		# Position: random XZ spread, fixed Y. The shader uses this only for
		# lateral offset — depth is driven by INSTANCE_CUSTOM.r below.
		var pos := Transform3D()
		pos = pos.translated(Vector3(
			spawn_area_center.x + randf_range(-1.0, 1.0) * spawn_area_size / 2.0,
			spawn_area_center.y,
			spawn_area_center.z + randf_range(-1.0, 1.0) * spawn_area_size / 2.0
		))
		multimesh.set_instance_transform(i, pos)

		# INSTANCE_CUSTOM.r distributes planes evenly from near to far.
		# The shader maps this 0..1 value to plane_offset_min..plane_offset_max.
		# Other channels (g, b, a) are free for future per-instance variation.
		var depth_fraction := float(i) / float(max(multimesh.instance_count - 1, 1))
		multimesh.set_instance_custom_data(i, Color(depth_fraction, 0.0, 0.0, 0.0))

func _process(_delta: float) -> void:
	if directional_light:
		var mat := multimesh.mesh.surface_get_material(0) as ShaderMaterial
		if mat:
			mat.set_shader_parameter("light_direction",
				-directional_light.global_transform.basis.z)

func _on_day_start():
	multimesh.visible_instance_count = number_of_meshes

func _on_day_over():
	multimesh.visible_instance_count = 0
