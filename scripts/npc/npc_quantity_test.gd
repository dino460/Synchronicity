extends Node

@export var number_of_npcs_to_spawn : int
@export var world_size : int
@export var label : Label

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for i in number_of_npcs_to_spawn:
		var new_home_scene = preload("res://scenes/home_template.tscn")
		var new_home_instance = new_home_scene.instantiate()
		var pos = Vector3(randf_range(-world_size,world_size), 0.0, randf_range(-world_size,world_size))
		new_home_instance.position = pos
		add_child(new_home_instance)

		var new_job_scene = preload("res://scenes/work_template.tscn")
		var new_job_instance = new_job_scene.instantiate()
		pos = Vector3(randf_range(-world_size,world_size), 0.0, randf_range(-world_size,world_size))
		new_job_instance.position = pos
		add_child(new_job_instance)

		var new_npc_scene = preload("res://scenes/npc_smart.tscn")
		var new_npc_instance = new_npc_scene.instantiate()
		pos = Vector3(randf_range(-world_size,world_size), 1.02, randf_range(-world_size,world_size))
		new_npc_instance.position = pos
		new_npc_instance.job = new_job_instance
		new_npc_instance.home = new_home_instance
		new_npc_instance.test_label = label
		print(new_npc_instance.job)
		add_child(new_npc_instance)
