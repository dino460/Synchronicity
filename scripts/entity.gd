extends Node3D

class_name Entity

signal trigger_death
signal damage_taken(int, Entity)
signal attack(animation_direction: AnimationHandler.AnimationState,is_attacking: bool)

signal enemy_killed(Entity)

@export var stats : CharacterStats

var damaged_enemies_this_attack : Array
var enemy_kill_list : Array[Entity]

@export var is_attacking       : bool = false
@export var can_combo          : bool = false
@export var should_attack_move : bool = false

@export var weapon                : Weapon

func take_damage(damage : int, attacker : Entity):
	# print("HP before: ", stats.health)
	stats.health -= damage
	damage_taken.emit(damage, attacker)

	if stats.health <= 0:
		is_attacking = false
		should_attack_move = false
		stats.health = 0
		trigger_death.emit()
		attacker.enemy_kill_list.append(self)
		attacker.enemy_killed.emit(self)
		return
	# print("HP after: ", stats.health)
	# print()

func do_attack(attack_state : AnimationHandler.AnimationState):
	# if (not is_attacking) or can_combo:
		# stats.stamina -= weapon.stamina_cost_per_attack.get(attack_state)
		# damaged_enemies_this_attack.clear()
	attack.emit(attack_state, is_attacking)
	print("here")

func damage_enemies():
	var hit_enemies = weapon.get_child(0).get_overlapping_bodies()
	var enemies_to_damage : Array = undamaged_enemies(hit_enemies)
	damaged_enemies_this_attack.append_array(enemies_to_damage)
	for enemy in enemies_to_damage: #Applies damage to enemies
		if enemy == self:
			continue
		if enemy.has_method("take_damage"): # Checks if enemy has take_damage method
			enemy.take_damage(weapon.attack_damage, self)
			# print(weapon.attack_damage)

func undamaged_enemies(enemies : Array) -> Array:
	var undamaged : Array = []
	for enemy in enemies:
		if not enemy in damaged_enemies_this_attack:
			undamaged.append(enemy)
	return undamaged

func start_attack_movement():
	should_attack_move = true

func stop_attack_movement():
	should_attack_move = false

func _on_animation_handler_attack_started():
	# stats.stamina -= weapon.stamina_cost_per_attack.get(attack_state)
	is_attacking = true
	# can_combo = false

func _on_animation_handler_attack_ended():
	is_attacking = false
	can_combo = false
