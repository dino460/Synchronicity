extends CharacterBody3D

class_name Entity

signal trigger_death
signal damage_taken(int, Entity)
signal attack(animation_direction: AnimationHandler.AnimationState, weapon: Weapon, is_attacking: bool)

@export var stats : CharacterStats

var damaged_enemies_this_attack : Array = []

@export var is_attacking       : bool = false
@export var can_combo          : bool = false
@export var should_attack_move : bool = false

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

func do_attack(attack_state : AnimationHandler.AnimationState, weapon : Weapon):
	if (not is_attacking) or can_combo:
		is_attacking = true
		should_attack_move = true
		can_combo = false
		damaged_enemies_this_attack.clear()
		attack.emit(attack_state, weapon, is_attacking)

func damage_enemies(weapon : Weapon):
	var hit_enemies = weapon.get_child(0).get_overlapping_bodies()
	if not damaged_enemies_this_attack.has(hit_enemies): # Checks if new enemies are hit
		# print(hit_enemies)
		damaged_enemies_this_attack.append(hit_enemies)
		for enemy in hit_enemies: #Applies damage to enemies
			if enemy.has_method("take_damage"): # Checks if enemy has take_damage method
				enemy.take_damage(weapon.attack_damage, self)
				# print(weapon.attack_damage)

func stop_attack_movement():
	should_attack_move = false

func _on_animation_handler_attack_ended():
	is_attacking = false
	can_combo = false
	should_attack_move = false
