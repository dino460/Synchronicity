extends Node

class_name Weapon

@export var type : String

@export var up_attack_animations : Array
@export var down_attack_animations : Array

@export var up_attack_time : float
@export var down_attack_time : float

@export var preferred_attack_stream : Array[PreferredNextAttack]

@export var attack_damage : float
