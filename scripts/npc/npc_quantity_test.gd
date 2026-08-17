extends Node

@export var number_of_npcs_to_spawn : int
@export var world_size : float
@export var npc_holder : Node
@export var viewport : SubViewport


func _ready() -> void:
	var start : float = -world_size / 2.0
	var spacing : float = world_size / number_of_npcs_to_spawn

	for i in number_of_npcs_to_spawn:

		var label : Label = Label.new()
		viewport.add_child(label)

		var new_npc_scene = preload("res://scenes/npc/npc.tscn")
		var new_npc_instance = new_npc_scene.instantiate()
		var pos = Vector3(0.0, 1.02, start + (i * spacing))
		new_npc_instance.position = pos
		npc_holder.add_child(new_npc_instance)
		new_npc_instance.label = label
