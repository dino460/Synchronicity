extends Node

class_name CharacterStats

## The maximum and current health of the character.
## Value is determined by the character's constitution.
var max_health : int
@export var health : int
## Modifier for the physical damage dealt by the character.
@export var strength : int = 1
## Modifier for the speed and attack speed of the character.
@export var agility : int = 1
## Determines character's resistance to physical damage.
## Determines maximum health.
@export var constitution : int = 1

var max_stamina : int
@export var stamina : int

func _ready():
	max_health = constitution * log(constitution) + 10
	health = max_health
	max_stamina = constitution * log(constitution) + 10
	stamina = max_stamina
