extends Node3D

class_name Item

enum Type {
	GENERIC,
	WEAPON,
	POTION,
	FOOD
}

@export var item_name : String
@export var item_type : Type = Type.GENERIC
