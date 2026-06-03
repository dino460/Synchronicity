extends Node3D

class_name Weapon

enum WeaponType {LSWRD, SSWRD, GSWRD, AXE, GAXE, SPR, DAG}
@export var type : WeaponType
enum WeaponGroup {BLADE, POLE, SMALL}
@export var group : WeaponGroup

# @export var attack_animations		: Dictionary[AnimationHandler.AnimationState, String]
@export_group("Combat Properties")
@export var attack_damage : float
@export var stamina_cost_per_stance : Dictionary[AnimationHandler.AttackStances, float]
@export var preferred_attack_stream : Array[PreferredNextAttack]

@export_group("Positioning Properties")
@export var weapon_hand_transform : Transform3D
@export var weapon_sheathe_transform : Transform3D


func get_type_string() -> String:
	return WeaponType.keys()[self.type]

func get_group_string() -> String:
	if group == null:
		match type:
			WeaponType.LSWRD, WeaponType.SSWRD, WeaponType.GSWRD, WeaponType.AXE:
				group = WeaponGroup.BLADE

			WeaponType.GAXE, WeaponType.SPR:
				group = WeaponGroup.POLE

			WeaponType.DAG:
				group = WeaponGroup.SMALL


	return WeaponGroup.keys()[self.type]

func is_preferred_attack(current_attack : AnimationHandler.AnimationState, next_attack : AnimationHandler.AnimationState) -> bool:
	for preference in preferred_attack_stream:
		if preference.this_attack == current_attack and preference.preferred_next == next_attack:
			return true
	return false
