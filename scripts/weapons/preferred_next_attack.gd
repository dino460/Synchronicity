extends Node

class_name PreferredNextAttack

var this_attack    : AnimationHandler.State
var preferred_next : AnimationHandler.State

func _init(this_attack_new, preferred_next_new) -> void:
	this_attack = this_attack_new
	preferred_next = preferred_next_new
