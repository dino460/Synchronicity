extends Node3D

class_name NPCState

var personality : Personality
var helper_thread : Thread

func start():
	pass

func run(position : Vector3, forward : Vector3):
	pass

func change_state(current_state : NPCState):
	pass
