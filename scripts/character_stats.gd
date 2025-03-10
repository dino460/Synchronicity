extends Node

class_name CharacterStats

## The maximum and current health of the character.
## Value is determined by the character's constitution.
var max_health : int
@export var health : int
## Modifier for the physical damage dealt by the character.
@export var strength : int
## Modifier for the speed and attack speed of the character.
@export var agility : int
## Determines character's resistance to physical damage.
## Determines maximum health.
@export var constitution : int

func _ready():
	max_health = log(constitution)
	health = max_health
