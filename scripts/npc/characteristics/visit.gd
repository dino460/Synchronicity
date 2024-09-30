extends Node

class_name Visit

func _init(new_landmark : Landmark) -> void:
	landmark = new_landmark
	number_of_visits = 1

@export var landmark : Landmark
@export var number_of_visits : int
