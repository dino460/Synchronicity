extends Node

class_name CharacterStats

## The maximum and current health of the character.
## Value is determined by the character's constitution.
var max_health : float
@export var health : float
## Modifier for the physical damage dealt by the character.
@export var strength : float = 1.0
## Modifier for the speed and attack speed of the character.
@export var agility : float = 1.0
## Determines character's resistance to physical damage.
## Determines maximum health.
@export var constitution : float = 1.0

var max_stamina : float
@export var stamina : float
var stamina_regen : float
@export var base_stamina_regen : float = 5.0

func _ready():
	max_health = constitution * (log(constitution) / log(10.0)) + 10.0
	health = max_health
	max_stamina = constitution * (log(constitution) / log(10.0)) + 10.0
	stamina = max_stamina

	stamina_regen = base_stamina_regen

func _process(delta: float) -> void:
	if stamina <= max_stamina:
		stamina += stamina_regen * delta
