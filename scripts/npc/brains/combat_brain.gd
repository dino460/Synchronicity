extends NPCBrain

func handle_combat_states():
	current_target = null

	if chase_reset_counter <= 0.0 or damage_per_aggroer[current_aggro_target] < damage_threshold:
		current_aggro_target = null
		current_state = State.DOING_STUFF
		current_combat_state = CombatState.NONE
		chase_reset_counter = chase_reset_time
		return

	# if can_see_aggro_target and not is_in_attack_range:
	# 	current_combat_state = CombatState.CHASING
	# 	wants_to_look_around = false
	# 	chase_reset_counter = chase_reset_time

	match current_combat_state:
		CombatState.NONE:
			pass

		CombatState.SEARCHING:
			chase_reset_counter -= get_physics_process_delta_time() * scheduler.number_of_groups

			if navigation_agent.is_navigation_finished():
				var change_search_area : bool = randf() < chance_to_change_search_area
				if change_search_area:
					print("changed search area")
					search_area_position = global_position

				current_combat_state = CombatState.LOOKING
				wait_to_search_timer = randf_range(min_time_to_wait, max_time_to_wait)

		CombatState.LOOKING:
			chase_reset_counter -= get_physics_process_delta_time() * scheduler.number_of_groups

			velocity = Vector3.ZERO
			navigation_enabled = false

			if wait_to_search_timer <= 0.0:
				var search_pos_x = search_area_position.x + randf_range(-search_radius, search_radius)
				var search_pos_z = search_area_position.z + randf_range(-search_radius, search_radius)
				var search_position = Vector3(search_pos_x, search_area_position.y, search_pos_z)
				set_movement_target(search_position)
				current_combat_state = CombatState.SEARCHING
			else:
				wait_to_search_timer -= get_physics_process_delta_time() * scheduler.number_of_groups

		CombatState.CHASING:
			if can_see_aggro_target:
				set_movement_target(current_aggro_target.position)
			elif navigation_agent.is_navigation_finished():
				current_combat_state = CombatState.SEARCHING
				search_area_position = global_position

		CombatState.CLOSE:
			velocity = self.position.direction_to(current_aggro_target.position) * get_speed()
			navigation_enabled = false
			if can_see_aggro_target:
				current_combat_state = CombatState.ATTACKING
				do_attack(AnimationHandler.AnimationState.ATTACK_LEFT, weapon_attatchment.get_children()[0])

		CombatState.ATTACKING:
			if not should_attack_move:
				velocity = Vector3.ZERO
				pass
			else:
				velocity = self.position.direction_to(current_aggro_target.position) * get_speed()
