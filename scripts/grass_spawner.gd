extends MultiMeshInstance3D

class_name GrassSpawner

var number_of_meshes : int
var spawn_area_size : float
var spawn_area_center : Vector3
var grass_mesh : MeshInstance3D

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
		var position = Transform3D()
		position = position.translated(Vector3(spawn_area_center.x + randf_range(-1.0, 1.0) * spawn_area_size / 2.0, spawn_area_center.y, spawn_area_center.z + randf_range(-1.0, 1.0) * spawn_area_size / 2.0))
		multimesh.set_instance_transform(i, position)
		multimesh.set_instance_custom_data(i, Color(randf(), randf(), randf(), randf()))
