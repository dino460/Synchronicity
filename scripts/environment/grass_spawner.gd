extends MultiMeshInstance3D

class_name GrassSpawner

var number_of_meshes : int
var spawn_area_size : float
var spawn_area_center : Vector3
var grass_mesh : MeshInstance3D

func _init(
	p_number_of_meshes : int = 0,
	p_spawn_area_size : float = 0.0,
	p_spawn_area_center : Vector3 = Vector3.ZERO,
	p_grass_mesh : MeshInstance3D = null,
) -> void:
	number_of_meshes = p_number_of_meshes
	spawn_area_size = p_spawn_area_size
	spawn_area_center = p_spawn_area_center
	grass_mesh = p_grass_mesh


func _ready():
	# Create the multimesh.
	# multimesh = MultiMesh.new()
	multimesh.use_custom_data = true
	# Set the format first.
	multimesh.transform_format = MultiMesh.TRANSFORM_3D
	# Then resize (otherwise, changing the format is not allowed).
	multimesh.instance_count = number_of_meshes
	# Maybe not all of them should be visible at first.
	multimesh.visible_instance_count = number_of_meshes

	multimesh.mesh = grass_mesh.mesh

	# Set the transform of the instances.
	for i in multimesh.visible_instance_count:
		var instance_position = Transform3D()
		instance_position = instance_position.translated(
			Vector3(
				randf_range(-spawn_area_size / 2.0, spawn_area_size / 2.0),
				spawn_area_center.y + (multimesh.mesh.size.y / 2.0),
				randf_range(-spawn_area_size / 2.0, spawn_area_size / 2.0)
			)
		)
		multimesh.set_instance_transform(i, instance_position)
		multimesh.set_instance_custom_data(i, Color(randf(), randf(), randf(), randf()))
