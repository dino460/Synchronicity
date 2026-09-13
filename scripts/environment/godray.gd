extends MultiMeshInstance3D

class_name Godray

var camera : Camera3D
var directional_light : DirectionalLight3D
var player : Player
var number_of_meshes : int
var random_spread : float
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
	# directional_light = get_viewport().find_child("DirectionalLight3D")

	var subdivisions : float = floor(sqrt(multimesh.visible_instance_count))
	var i : float = floor(sqrt(multimesh.visible_instance_count))
	var j : float = floor(sqrt(multimesh.visible_instance_count))

	print(spawn_area_center, " ", player.global_position)
	for index in range(multimesh.visible_instance_count):
		var mesh_position : Vector3 = Vector3.ZERO
		var center_correction : float = spawn_area_center.x - spawn_area_size / 2.0
		var x_randomness : float = randf_range(-random_spread, random_spread)
		var z_randomness : float = randf_range(-random_spread, random_spread)

		mesh_position.x = center_correction + (i * spawn_area_size / subdivisions) + x_randomness
		mesh_position.z = center_correction + (j * spawn_area_size / subdivisions) + z_randomness
		print(mesh_position)

		var pos := Transform3D()
		# pos = pos.translated(Vector3(
		# 	spawn_area_center.x + randf_range(-1.0, 1.0) * spawn_area_size / 2.0,
		# 	spawn_area_center.y,
		# 	spawn_area_center.z + randf_range(-1.0, 1.0) * spawn_area_size / 2.0
		# ))
		pos = pos.translated(mesh_position)
		multimesh.set_instance_transform(index, pos)

		i -= 1
		if i <= 0.0:
			i = floor(sqrt(multimesh.visible_instance_count))
			j -= 1

func _process(_delta: float) -> void:
	self.position = player.global_position

	if directional_light:
		var mat := multimesh.mesh.surface_get_material(0) as ShaderMaterial
		if mat:
			mat.set_shader_parameter("light_direction",
				-directional_light.global_transform.basis.z)


func _on_day_start():
	multimesh.visible_instance_count = number_of_meshes

func _on_day_over():
	multimesh.visible_instance_count = 0
