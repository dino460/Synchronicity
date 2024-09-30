extends Node

@export var number_of_npcs_to_spawn : int
@export var world_size : int
@export var npc_holder : Node
@export var label : Label

func _ready() -> void:
	var counter : float = 0.0
	var start : float = -world_size / 2.0
	var spacing : float = world_size / number_of_npcs_to_spawn

	for i in number_of_npcs_to_spawn:
		var new_home_scene = preload("res://scenes/home_template.tscn")
		var new_home_instance = new_home_scene.instantiate()
		var pos = Vector3(15.0, 0.0, start + (counter * spacing))
		new_home_instance.position = pos
		add_child(new_home_instance)

		var new_job_scene = preload("res://scenes/work_template.tscn")
		var new_job_instance = new_job_scene.instantiate()
		pos = Vector3(-15.0, 0.0, start + (counter * spacing))
		new_job_instance.position = pos
		add_child(new_job_instance)

		var new_npc_scene = preload("res://scenes/npc_smart.tscn")
		var new_npc_instance = new_npc_scene.instantiate()
		pos = Vector3(0.0, 1.02, start + (counter * spacing))
		new_npc_instance.position = pos
		new_npc_instance.job = new_job_instance
		new_npc_instance.home = new_home_instance
		new_npc_instance.test_label = label
		npc_holder.add_child(new_npc_instance)

		counter += 1.0
