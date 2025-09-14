extends Node3D

class_name CombatBrain

enum CombatState { NONE, LOOKING, SEARCHING, CHASING, CLOSE, ATTACKING }
var current_combat_state : CombatState = CombatState.NONE
var next_combat_state : CombatState = CombatState.NONE

enum CombatDirection { NONE, UP, DOWN, LEFT, RIGHT }
var current_combat_direction : CombatDirection = CombatDirection.LEFT

@export var weapon_attatchment : Node3D
var weapon : Weapon

var damage_per_aggressor : Dictionary[Entity, float] = { null : -100000000.0}
var current_aggressor : Entity
@export var damage_threshold : float = 0.0
@export var damage_dissipation : float = 0.5

var attack_distance : float = 5.0

var desired_velocity : Vector3
var desired_target_position : Vector3

@export var field_of_view : float = -0.35

var looking_base_time : float
var looking_time_counter : float = 0.0
@export var looking_time : float
@export var looking_time_variance : float = 2.2

var last_known_aggressor_position : Vector3
var search_position : Vector3
@export var search_radius : float = 10.0

func _ready() -> void:
	weapon = weapon_attatchment.get_children()[0]
	# looking_base_time = (npc_ref.personality.mind * (1 - npc_ref.personality.aggression) / (npc_ref.personality.energy * npc_ref.personality.bravery))


## The first element must ALWAYS be the current combat state
## The second element is ALWAYS the position to move to
## The third element is the desired animation state of the NPC (one of the four directional attacks)
## The fourth element is the desired velocity of the NPC
func handle_combat(delta : float, npc_ref : NPC) -> Dictionary:
	current_combat_state = next_combat_state

	var target_position : Vector3
	var velocity : Vector3

	var converted_animation_state : AnimationHandler.AnimationState

	tick_aggressor_damage(delta)
	var higher_aggressor : Entity = get_higher_aggressor()
	current_aggressor = higher_aggressor

	if damage_per_aggressor[current_aggressor] < damage_threshold:
		current_combat_state = CombatState.NONE

	match current_combat_state:
		CombatState.NONE:
			if not damage_per_aggressor.is_empty() and damage_per_aggressor[higher_aggressor] >= damage_threshold:
				next_combat_state = CombatState.CHASING

		CombatState.LOOKING:
			looking_time_counter += delta

			if looking_time_counter >= looking_time:
				var search_pos_x : float = last_known_aggressor_position.x + randf_range(-search_radius, search_radius)
				var search_pos_z : float = last_known_aggressor_position.z + randf_range(-search_radius, search_radius)
				search_position = Vector3(search_pos_x, last_known_aggressor_position.y, search_pos_z)
				next_combat_state = CombatState.SEARCHING

		CombatState.SEARCHING:
			if can_see_aggressor(npc_ref):
				if is_agressor_in_attack_range(npc_ref):
					next_combat_state = CombatState.ATTACKING
				else:
					next_combat_state = CombatState.CHASING
			elif npc_ref.navigation_agent.is_navigation_finished():
				next_combat_state = CombatState.LOOKING
				looking_time = looking_base_time + randf_range(1.0, looking_time_variance)
				looking_time_counter = 0.0
			else:
				target_position = search_position

		CombatState.CHASING:
			if is_agressor_in_attack_range(npc_ref):
				next_combat_state = CombatState.ATTACKING
			elif not can_see_aggressor(npc_ref):
				last_known_aggressor_position = current_aggressor.global_position
				next_combat_state = CombatState.SEARCHING
				var search_pos_x : float = last_known_aggressor_position.x + randf_range(-search_radius, search_radius)
				var search_pos_z : float = last_known_aggressor_position.z + randf_range(-search_radius, search_radius)
				search_position = Vector3(search_pos_x, last_known_aggressor_position.y, search_pos_z)
			else:
				target_position = current_aggressor.global_position

		# CombatState.CLOSE:
		# 	if can_see_aggressor(npc_ref):
		# 		next_combat_state = CombatState.ATTACKING
		# 	else:
		# 		next_combat_state = CombatState.SEARCHING

		CombatState.ATTACKING:
			converted_animation_state = convert_combat_direction_to_animation_state()
			print(converted_animation_state)

			if not can_see_aggressor(npc_ref):
				next_combat_state = CombatState.SEARCHING
			elif not is_agressor_in_attack_range(npc_ref):
				next_combat_state = CombatState.CHASING
			elif weapon.stamina_cost_per_attack.get(converted_animation_state) <= npc_ref.stats.stamina:
				velocity = npc_ref.global_position.direction_to(current_aggressor.global_position).normalized()
				# return {
				# 	"current_combat_state" : current_combat_state,
				# 	"target_position" : null,
				# 	"converted_animation_state" : converted_animation_state,
				# 	"velocity" : velocity
				# }

	return {
		"current_combat_state" : current_combat_state,
		"target_position" : target_position,
		"converted_animation_state" : converted_animation_state,
		"velocity" : velocity,
		"weapon" : weapon,
	} # Returns a false signal to indicate that the NPC is not ready to attack


func can_see_aggressor(npc_ref : NPC) -> bool:
	if current_aggressor == null:
		return false

	var space_state = get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(npc_ref.look_origin.global_position, current_aggressor.global_position, 1)
	var	result = space_state.intersect_ray(query)

	var direction_to_agressor : Vector3 = npc_ref.position.direction_to(current_aggressor.position).normalized()
	var is_in_field_of_view : bool = (-npc_ref.mesh_pivot_ref.global_transform.basis.z).dot(direction_to_agressor) > field_of_view

	return result.collider == current_aggressor and is_in_field_of_view

func is_agressor_in_attack_range(npc_ref : NPC) -> bool:
	var distance_to_agressor : float = npc_ref.position.distance_to(current_aggressor.global_position)
	return distance_to_agressor < attack_distance

func convert_combat_direction_to_animation_state() -> AnimationHandler.AnimationState:
	match current_combat_direction:
		CombatDirection.UP:
			return AnimationHandler.AnimationState.ATTACK_UP
		CombatDirection.DOWN:
			return AnimationHandler.AnimationState.ATTACK_DOWN
		CombatDirection.RIGHT:
			return AnimationHandler.AnimationState.ATTACK_RIGHT
		_:
			return AnimationHandler.AnimationState.ATTACK_LEFT

func tick_aggressor_damage(delta : float):
	for entity in damage_per_aggressor:
		if entity == current_aggressor:
			damage_per_aggressor[entity] -= damage_dissipation * delta * 0.5
		elif entity != null:
			damage_per_aggressor[entity] -= damage_dissipation * delta

		if damage_per_aggressor[entity] <= 0 and entity != null:
			damage_per_aggressor.erase(entity)

func get_higher_aggressor() -> Entity:
	var max_damage : float = 0
	var higher_aggressor : Entity = null

	for entity in damage_per_aggressor:
		if damage_per_aggressor[entity] > max_damage:
			max_damage = damage_per_aggressor[entity]
			higher_aggressor = entity

	return higher_aggressor

func _on_damage_taken(damage : int, new_attacker : Entity) -> void:
	print("taking damage: ", damage, " from ", new_attacker)
	if damage_per_aggressor.has(new_attacker):
		damage_per_aggressor[new_attacker] += damage
	else:
		damage_per_aggressor[new_attacker] = damage

	if current_aggressor == null:
		current_aggressor = new_attacker
		return
	else:
		for attacker in damage_per_aggressor:
			if damage_per_aggressor[attacker] > damage_per_aggressor[current_aggressor]:
				current_aggressor = attacker
