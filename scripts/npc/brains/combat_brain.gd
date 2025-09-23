extends Node3D

class_name CombatBrain

enum CombatState { NONE, LOOKING, SEARCHING, CHASING, ATTACKING, CLOSE }
var current_combat_state : CombatState = CombatState.NONE
var next_combat_state : CombatState = CombatState.NONE

enum CombatDirection { NONE, UP, DOWN, LEFT, RIGHT }
var current_combat_direction : CombatDirection = CombatDirection.LEFT

var attack_distance : float = 2.5

var desired_velocity : Vector3
var desired_target_position : Vector3
var run : bool = false

@export var this_npc_ref : NPC

@export_group("Weapon")
@export var weapon_attatchment : Node3D
var weapon : Weapon

@export_group("Damage Handling")
var damage_per_aggressor : Dictionary[Entity, float] = { null : -100000000.0}
var current_aggressor : Entity
@export var damage_threshold : float = 0.0
@export var damage_dissipation : float = 0.5

@export_group("Look & Search")
var looking_base_time : float
var looking_time_counter : float = 0.0
@export var looking_time : float
@export var looking_time_variance : float = 2.2

@export var field_of_view : float = -0.35

var last_known_aggressor_position : Vector3
var search_position : Vector3
@export var search_radius : float = 10.0
@export var max_wandering_distance : float = 50.0
@export var aggressor_position_prediction_weight : float = 5.0
@export_range(0.01, 1.0, 0.01)
var real_aggressor_velocity_weight : float = 0.4

@export var look_origin : Node3D
var can_see_target : bool = false
var could_see_target : bool = false


func _ready() -> void:
	weapon = weapon_attatchment.get_children()[0]
	# looking_base_time = (this_npc_ref.personality.mind * (1 - this_npc_ref.personality.aggression) / (this_npc_ref.personality.energy * this_npc_ref.personality.bravery))

func _physics_process(delta: float) -> void:
	can_see_target = can_see_aggressor()

## The first element must ALWAYS be the current combat state
## The second element is ALWAYS the position to move to
## The third element is the desired animation state of the NPC (one of the four directional attacks)
## The fourth element is the desired velocity of the NPC
func handle_combat(delta : float) -> Dictionary:
	current_combat_state = next_combat_state

	var target_position : Vector3

	var converted_animation_state : AnimationHandler.AnimationState = convert_combat_direction_to_animation_state()

	var higher_aggressor : Entity = get_higher_aggressor()
	current_aggressor = higher_aggressor

	if damage_per_aggressor[current_aggressor] < damage_threshold:
		current_combat_state = CombatState.NONE

	match current_combat_state:
		CombatState.NONE:
			tick_aggressor_damage(delta)

			if not damage_per_aggressor.is_empty() and damage_per_aggressor[higher_aggressor] >= damage_threshold:
				next_combat_state = CombatState.CHASING

		CombatState.LOOKING:
			run = false
			tick_aggressor_damage(delta)

			looking_time_counter += delta
			if is_agressor_in_attack_range():
				next_combat_state = CombatState.ATTACKING
			elif can_see_target and could_see_target:
				next_combat_state = CombatState.CHASING
			elif looking_time_counter >= looking_time:
				var search_pos_x : float = last_known_aggressor_position.x + randf_range(-search_radius, search_radius)
				var search_pos_z : float = last_known_aggressor_position.z + randf_range(-search_radius, search_radius)
				var candidate_position = Vector3(search_pos_x, last_known_aggressor_position.y, search_pos_z)
				# if can_see_position(candidate_position):
				search_position = candidate_position
				next_combat_state = CombatState.SEARCHING

		CombatState.SEARCHING:
			tick_aggressor_damage(delta)

			target_position = search_position

			if is_agressor_in_attack_range():
				next_combat_state = CombatState.ATTACKING
			elif can_see_target and could_see_target:
				next_combat_state = CombatState.CHASING
			elif this_npc_ref.navigation_agent.is_navigation_finished():
				next_combat_state = CombatState.LOOKING
				looking_time = looking_base_time + randf_range(1.0, looking_time_variance)
				looking_time_counter = 0.0

		CombatState.CHASING:
			run = true

			target_position = current_aggressor.global_position
			if is_agressor_in_attack_range():
				next_combat_state = CombatState.ATTACKING
			elif not can_see_target and not could_see_target:
				set_search_position(get_predicted_aggressor_position())
				next_combat_state = CombatState.SEARCHING

		CombatState.CLOSE:
			if not is_agressor_in_attack_range():
				run = true
				if not can_see_target:
					set_search_position(get_predicted_aggressor_position())
					next_combat_state = CombatState.SEARCHING
				else:
					next_combat_state = CombatState.CHASING
			elif weapon.stamina_cost_per_attack.get(converted_animation_state) <= this_npc_ref.stats.stamina and not this_npc_ref.is_attacking:
				next_combat_state = CombatState.ATTACKING

		CombatState.ATTACKING:
			if not is_agressor_in_attack_range():
				run = true
				if not can_see_target:
					set_search_position(get_predicted_aggressor_position())
					next_combat_state = CombatState.SEARCHING
				else:
					next_combat_state = CombatState.CHASING
			# elif weapon.stamina_cost_per_attack.get(converted_animation_state) >= this_npc_ref.stats.stamina:
				# next_combat_state = CombatState.CLOSE
			else:
				run = false
				target_position = current_aggressor.global_position
				next_combat_state = CombatState.CLOSE

	return {
		"current_combat_state" : current_combat_state,
		"target_position" : target_position,
		"converted_animation_state" : converted_animation_state,
		"weapon" : weapon,
		"run" : run
	}


func can_see_aggressor() -> bool:
	if current_aggressor == null:
		return false

	var space_state = get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(look_origin.global_position, current_aggressor.global_position, 1)
	var	result = space_state.intersect_ray(query)

	var direction_to_agressor : Vector3 = this_npc_ref.global_position.direction_to(current_aggressor.global_position).normalized()
	var is_in_field_of_view : bool = (-this_npc_ref.mesh_pivot_ref.global_transform.basis.z).dot(direction_to_agressor) > field_of_view

	if can_see_target == true:
		could_see_target = true
	else:
		could_see_target = false

	can_see_target = result.collider == current_aggressor and is_in_field_of_view
	return can_see_target

func can_see_search_position() -> bool:
	var space_state = get_world_3d().direct_space_state
	var look_position = Vector3(search_position.x, look_origin.global_position.y, search_position.z)
	var query = PhysicsRayQueryParameters3D.create(look_origin.global_position, look_position)
	var result = space_state.intersect_ray(query)

	return result.collider == null

func is_agressor_in_attack_range() -> bool:
	var distance_to_agressor : float = self.global_position.distance_squared_to(current_aggressor.global_position)
	return distance_to_agressor <= attack_distance

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

func set_search_position(aggressor_position : Vector3):
	# var mesh = MeshInstance3D.new()
	# var sphere = SphereMesh.new()
	# sphere.radius = 1.0
	# mesh.mesh = sphere
	# get_tree().root.add_child(mesh)
	# mesh.global_position = Vector3(aggressor_position.x, 0.0, aggressor_position.z)

	last_known_aggressor_position = Vector3(aggressor_position.x, 0.0, aggressor_position.z)
	search_position = last_known_aggressor_position

func get_predicted_aggressor_position() -> Vector3:
	var predicted_direction_correction = (current_aggressor.global_position - self.global_position).normalized() * aggressor_position_prediction_weight
	var real_direction_correction = current_aggressor.velocity * real_aggressor_velocity_weight
	var predicted_position = current_aggressor.global_position + predicted_direction_correction + real_direction_correction

	return predicted_position

func _on_damage_taken(damage : int, new_attacker : Entity) -> void:
	# print("taking damage: ", damage, " from ", new_attacker)
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
