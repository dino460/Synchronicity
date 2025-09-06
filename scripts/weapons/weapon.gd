extends Node

class_name Weapon

@export var type : String

@export var attack_animations		: Dictionary
@export var preferred_attack_stream : Array[PreferredNextAttack]
@export var stamina_cost_per_attack : Dictionary

@export var attack_damage : float

func is_preferred_attack(current_attack : AnimationHandler.AnimationState, next_attack : AnimationHandler.AnimationState) -> bool:
	for preference in preferred_attack_stream:
		if preference.this_attack == current_attack and preference.preferred_next == next_attack:
			return true
	return false
