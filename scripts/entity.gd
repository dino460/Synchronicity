extends CharacterBody3D

class_name Entity

signal trigger_death
signal damage_taken(int, Entity)

@export var stats : CharacterStats

func take_damage(damage : int, attacker : Entity):
	print("HP before: ", stats.health)
	stats.health -= damage
	if stats.health <= 0:
		stats.health = 0
		trigger_death.emit()
		return
	print("HP after: ", stats.health)
	print()
	damage_taken.emit(damage, attacker)
