extends Node


# @export_range(24000, 400000, 8000) var total_number_of_meshes : int = 40000
@export_enum("Off:0", "Potato:8000", "Ultra Low:24000", "Very Low:40000", "Low:80000", "Low/Medium:104000", "Medium:240000", "High:320000", "Very High:400000", "Ultra:640000")
var level_of_detail : int = 0
@export var total_number_of_meshes : int = 8000

@export_enum("Single:1", "Quarters:4", "Eights:16", "Many:64", "A Lot:256", "A Lot More:1024") var number_of_groups : int = 4
@export var ground_mesh : MeshInstance3D
@export var godray_mesh : MeshInstance3D

@export var scheduler : Scheduler

func _ready() -> void:
	if level_of_detail != 0:
		total_number_of_meshes = level_of_detail

	if total_number_of_meshes == 0:
		return

	var counter : int = sqrt(number_of_groups)
	var mult_factor_x : float = - (sqrt(number_of_groups) - 1.0)
	var mult_factor_z : float = - (sqrt(number_of_groups) - 1.0)
	var increment : int = 2
	var denominator : float = sqrt(number_of_groups) * 2.0

	for i in range(number_of_groups):
		var multimesh_instance = Godray.new()
		multimesh_instance.number_of_meshes = total_number_of_meshes / number_of_groups
		multimesh_instance.spawn_area_size = ground_mesh.mesh.size.x / sqrt(number_of_groups)

		var new_center_x = ground_mesh.global_position.x + (mult_factor_x * ground_mesh.mesh.size.x / denominator)
		var new_center_z = ground_mesh.global_position.z + (mult_factor_z * ground_mesh.mesh.size.x / denominator)
		multimesh_instance.spawn_area_center = Vector3(new_center_x, ground_mesh.global_position.y, new_center_z)

		mult_factor_x += increment
		counter -= 1
		if counter <= 0:
			counter = sqrt(number_of_groups)
			mult_factor_x = - (sqrt(number_of_groups) - 1.0)
			mult_factor_z += increment

		multimesh_instance.godray_mesh = godray_mesh
		multimesh_instance.multimesh = MultiMesh.new()
		multimesh_instance.cast_shadow = false
		multimesh_instance.scheduler = scheduler
		add_child(multimesh_instance)
