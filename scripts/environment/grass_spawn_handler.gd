extends Node


# @export_range(24000, 400000, 8000) var total_number_of_meshes : int = 40000

@export var total_number_of_meshes : int = 0

@export_enum("Single:1", "Quarters:4", "Eights:16", "Many:64", "A Lot:256", "A Lot More:1024")
var number_of_groups : int = 4

@export var ground_mesh : MeshInstance3D
@export var grass_mesh : MeshInstance3D

@export_group("Following Grid")
@export var use_following_grid : bool
@export var player : Player
@export var camera_reference : Camera3D
@export var spawn_area_side_length : float
@export_range(2, 12, 1) var number_of_groups_x : int = 2
@export_range(2, 12, 1) var number_of_groups_z : int = 2
var grid_center : Vector3 = Vector3.ZERO


func _ready() -> void:
	grid_center = player.global_position
	grid_center.x -= spawn_area_side_length * 2.0
	grid_center.z -= spawn_area_side_length * 3.0

	if use_following_grid:
		spawn_in_grid()
	else:
		total_number_of_meshes = GlobalSettings.grass_density

		if total_number_of_meshes == 0:
			return

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

			mult_factor_x += increment
			counter -= 1
			if counter <= 0:
				counter = sqrt(number_of_groups)
				mult_factor_x = - (sqrt(number_of_groups) - 1.0)
				mult_factor_z += increment

			multimesh_instance.grass_mesh = grass_mesh
			multimesh_instance.multimesh = MultiMesh.new()
			multimesh_instance.cast_shadow = false
			add_child(multimesh_instance)
			multimesh_instance.global_position = Vector3(new_center_x, 0.0, new_center_z)


func _physics_process(_delta: float) -> void:
	if use_following_grid: move_grass_in_grid()
	pass


## ========= Known working values ========= ##
##
##		spawn_area_side_length = 36~37
##		2 x 2 groups
##		distance_check_offset = 1.0
##		distance_move_offset = 2.0
##		center offset = (0.0, 0.0)
## 		total grass = 75168
## 		resolution = 2560x1080
##
##		spawn_area_side_length = 9
##		5 x 5 groups
##		distance_check_offset = 2.5
##		distance_move_offset = 5.0
##		center offset = (
## 			spawn_area_side_length * 2.0,
## 			spawn_area_side_length * 2.0
## 		)
## 		total grass = 29362
## 		resolution = 2560x1080
##
## 	All of this can be improved by separating
## 	X and Z axis checks (for example, using a
## 	5x4 grid, which reduces number of grass to
## 	23490 or -20%). That is easy and should be
## 	implemented ASAP for free memory gains.
## ========= ===================== ========= ##


func spawn_in_grid() -> void:
	var number_of_grasses_to_spawn : int = floor(spawn_area_side_length * spawn_area_side_length * 14.5)

	for i in number_of_groups_x:
		for j in number_of_groups_z:
			var mesh := MeshInstance3D.new()
			mesh.mesh = SphereMesh.new()
			var spawn_center : Vector3 = Vector3(grid_center.x + i * spawn_area_side_length, ground_mesh.global_position.y, grid_center.z + j * spawn_area_side_length)
			var multimesh_instance = GrassSpawner.new(number_of_grasses_to_spawn, spawn_area_side_length, spawn_center, grass_mesh)
			multimesh_instance.multimesh = MultiMesh.new()
			multimesh_instance.cast_shadow = false
			add_child(multimesh_instance)
			multimesh_instance.global_position = spawn_center
			multimesh_instance.add_child(mesh)
			mesh.global_position = multimesh_instance.global_position
			mesh.global_position.y = 2.0


func move_grass_in_grid() -> void:
	var player_direction := Vector2(
		player.direction.x / max(0.0001, abs(player.direction.x)),
		player.direction.z / max(0.0001, abs(player.direction.z))
	)
	var camera_facing_dir := Vector2(
		(player.global_position.x - camera_reference.global_position.x) / max(0.0001, abs(player.global_position.x - camera_reference.global_position.x)),
		(player.global_position.z - camera_reference.global_position.z) / max(0.0001, abs(player.global_position.z - camera_reference.global_position.z))
	)
	print(camera_facing_dir, " ", player_direction)

	for grass_patch : Node3D in self.get_children():
		var distance_check_offset_x     : float = 2.0
		var distance_check_offset_neg_x : float = 2.0

		var distance_move_offset_x      : float = 4.0
		var distance_move_offset_neg_x  : float = 4.0

		var x_distance : float = abs(grass_patch.global_position.x - player.global_position.x)
		var x_direction : float = (grass_patch.global_position.x - player.global_position.x) / abs(grass_patch.global_position.x - player.global_position.x)

		var distance_check_offset_z     : float = 2.5
		var distance_check_offset_neg_z : float = 1.5

		var distance_move_offset_z      : float = 4.0
		var distance_move_offset_neg_z  : float = 4.0

		var z_distance : float = abs(grass_patch.global_position.z - player.global_position.z)
		var z_direction : float = (grass_patch.global_position.z - player.global_position.z) / abs(grass_patch.global_position.z - player.global_position.z)

		## Check if player is going EAST (+x) and patch is WEST (-x)
		if x_distance >= spawn_area_side_length * distance_check_offset_x and x_direction < 0.0 and player_direction.x > 0.0:
			grass_patch.global_position.x += distance_move_offset_x * player_direction.x * spawn_area_side_length

		## Check if player is going WEST (-x) and patch is EAST (+x)
		if x_distance >= spawn_area_side_length * distance_check_offset_neg_x and x_direction > 0.0 and player_direction.x < 0.0:
			grass_patch.global_position.x += distance_move_offset_neg_x * player_direction.x * spawn_area_side_length

		## Check if player is going SOUTH (+z) and patch is NORTH (-z)
		## Flip distance used in check according to camera facing direction.
		## This compensates "perspective" change.
		var distance_check : float = distance_check_offset_z if camera_facing_dir.y < 0.0 else distance_check_offset_neg_z
		if z_distance >= spawn_area_side_length * distance_check and z_direction < 0.0 and player_direction.y > 0.0:
			grass_patch.global_position.z += distance_move_offset_z * player_direction.y * spawn_area_side_length

		## Check if player is going NORTH (-z) and patch is SOUTH (+z)
		## Flip distance used in check according to camera facing direction.
		## This compensates "perspective" change.
		distance_check = distance_check_offset_neg_z if camera_facing_dir.y < 0.0 else distance_check_offset_z
		if z_distance >= spawn_area_side_length * distance_check_offset_neg_z and z_direction > 0.0 and player_direction.y < 0.0:
			grass_patch.global_position.z += distance_move_offset_neg_z * player_direction.y * spawn_area_side_length
