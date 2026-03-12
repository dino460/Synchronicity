extends Node

class_name CharacterStats

@export var is_npc : bool = true

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

@export_group("Resources")
@export_subgroup("Hunger")
@export var hunger            : float
@export var max_hunger        : float = 100.0
@export var base_hunger_drain : float

@export_subgroup("Rest")
@export var rest            : float
@export var max_rest        : float = 100.0
@export var base_rest_drain : float

@export_subgroup("Motivation")
@export var motivation            : float
@export var max_motivation        : float = 100.0
@export var base_motivation_drain : float

@export var reputation : float


func _ready():
	max_health = constitution * (log(constitution) / log(10.0)) + 10.0
	health = max_health
	max_stamina = constitution * (log(constitution) / log(10.0)) + 10.0
	stamina = max_stamina

	stamina_regen = base_stamina_regen

	hunger = max_hunger
	rest = max_rest
	motivation = max_motivation

func _process(delta: float) -> void:

	if stamina <= max_stamina:
		stamina += stamina_regen * delta

	if is_npc:
		if hunger > 0.0:
			hunger -= base_hunger_drain * delta
		if rest > 0.0:
			rest -= base_rest_drain * delta
		if motivation > 0.0:
			motivation -= base_motivation_drain * delta
