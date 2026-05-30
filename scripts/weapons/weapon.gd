extends Node3D

class_name Weapon

enum WEAPON_TYPE {LSWRD, SSWRD, GSWRD, AXE, GAXE, SPR, DAG}
@export var type : WEAPON_TYPE

enum WEAPON_GROUP {BLADE, POLE, SMALL}
@export var group : WEAPON_GROUP

# @export var attack_animations		: Dictionary[AnimationHandler.AnimationState, String]
@export var preferred_attack_stream : Array[PreferredNextAttack]

@export var stamina_cost_per_attack : Dictionary[AnimationHandler.AnimationState, float]

@export var attack_damage : float

func get_type_string() -> String:
	return WEAPON_TYPE.keys()[self.type]

func get_group_string() -> String:
	if group == null:
		match type:
			WEAPON_TYPE.LSWRD, WEAPON_TYPE.SSWRD, WEAPON_TYPE.GSWRD, WEAPON_TYPE.AXE:
				group = WEAPON_GROUP.BLADE

			WEAPON_TYPE.GAXE, WEAPON_TYPE.SPR:
				group = WEAPON_GROUP.POLE

			WEAPON_TYPE.DAG:
				group = WEAPON_GROUP.SMALL


	return WEAPON_GROUP.keys()[self.type]

func is_preferred_attack(current_attack : AnimationHandler.AnimationState, next_attack : AnimationHandler.AnimationState) -> bool:
	for preference in preferred_attack_stream:
		if preference.this_attack == current_attack and preference.preferred_next == next_attack:
			return true
	return false
