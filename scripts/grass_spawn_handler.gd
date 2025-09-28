extends Node


@export_range(24000, 400000, 8000) var total_number_of_meshes : int = 40000
@export_enum("Single:1", "Few:4", "Some:16", "Many:64") var number_of_groups : int = 4
@export var ground_mesh : MeshInstance3D
@export var grass_mesh : MeshInstance3D

func _ready() -> void:
	var counter : int = sqrt(number_of_groups)
	var mult_factor_x : float = - (sqrt(number_of_groups) - 1.0)
	var mult_factor_z : float = - (sqrt(number_of_groups) - 1.0)
	var increment : int = 2
	var denominator : float = sqrt(number_of_groups) * 2.0

	for i in range(number_of_groups):
		var multimesh_instance = GrassSpawner.new()
		multimesh_instance.number_of_meshes = total_number_of_meshes / number_of_groups
		multimesh_instance.spawn_area_size = ground_mesh.mesh.size.x / sqrt(number_of_groups)

		var new_center_x = ground_mesh.global_position.x + (mult_factor_x * ground_mesh.mesh.size.x / denominator)
		var new_center_z = ground_mesh.global_position.z + (mult_factor_z * ground_mesh.mesh.size.x / denominator)
		multimesh_instance.spawn_area_center = Vector3(new_center_x, ground_mesh.global_position.y, new_center_z)
		print(multimesh_instance.spawn_area_center)

		mult_factor_x += increment
		counter -= 1
		if counter <= 0:
			print("0")
			counter = sqrt(number_of_groups)
			mult_factor_x = - (sqrt(number_of_groups) - 1.0)
			mult_factor_z += increment

		multimesh_instance.grass_mesh = grass_mesh
		multimesh_instance.multimesh = MultiMesh.new()
		add_child(multimesh_instance)
