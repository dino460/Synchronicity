extends Entity

class_name NPC

const base_move_speed     : float = 3.5
const base_run_multiplier : float = 2.67

signal idling
signal walking
signal death
signal running
# signal attack(animation_direction: AnimationHandler.AnimationState, weapon: Weapon, is_attacking: bool)

# enum State { DOING_STUFF, MOVING_ABOUT, SLEEPING, DEAD, FIGHTING }
# var _current_state : State = State.DOING_STUFF

# enum CombatState { NONE, SEARCHING, CHASING, CLOSE, ATTACKING, LOOKING }
# var current_combat_state : CombatState = CombatState.NONE

# @export var thoughts_label : Label
# @export var label_anchor : Node3D
var viewport : Viewport

var is_dead : bool = false

@export var mesh : MeshInstance3D

@export_group("NPC Identity")
@export var npc_name : String
@export var id       : int
var process_group    : int

@export_group("NPC Scheduling")
# @export var timers    : Dictionary
@export var scheduler : Scheduler
@export var npc_brain : NPCBrain

@export_group("NPC Characteristics")
@export var current_age        : int
@export var cycles_to_next_age : int
@export var personality        : Personality

@export_group("NPC Landmarks")
@export var job                : Job
@export var home               : Home
@export var visits             : Dictionary
@export var points_of_interest : Array[Landmark]

# @export var average_poi_distance : float

# @export_group("NPC Work")
# @export var has_worked_today   : bool = false

# var work_time_this_day         : float = 0.0
# var moving_about_time_this_day : float = 0.0
# var awake_time_this_day        : float = 0.0

# var want_to_sleep       : bool = false
# var sleep_amount_wanted : float = 0.0
# var sleep_counter       : float = 0.0

@export_group("NPC Navigation")
@onready var navigation_agent : NavigationAgent3D = $NavigationAgent3D
@export var max_stuck_time : float = 1.2
var stuck_timer : float = 0.0
var last_position : Vector3 = Vector3.ZERO
# @export  var look_origin      : Node3D

# var current_target   : Landmark
# var current_location : Landmark
# var last_location    : Landmark

# var is_at_job  : bool = false
# var is_at_home : bool = false

@export_group("NPC Movement")
var is_running         : bool = false
var look_direction     : Vector3 = Vector3.ZERO
var look_target        : Vector3 = Vector3.ZERO
# var navigation_enabled : bool = false
@export var minimum_movement_distance : float = 1.5

# @export_group("NPC Combat")
# var damage_per_aggroer  : Dictionary[Entity, float]
# var current_aggro_target  : Entity
# var can_see_aggro_target  : bool = false

# @export var damage_threshold  : float = 8.0
# @export var damage_drain_rate : float = 0.4

# @export_subgroup("Search Parameters")
# var wait_to_search_timer  : float = 0.0
# var chase_reset_counter   : float = 0.0
# var chase_reset_time      : float = 0.0
# var chase_reset_base_time : float = 0.0
# var search_area_position  : Vector3 = Vector3.ZERO

# @export var follow_look_angle  : float = 0.349055556
# @export var field_of_view      : float = -0.35
# @export var search_radius      : float = 5.0
# @export var run_mult_threshold : float = 1.8

# @export var max_time_to_wait : float = 2.5
# @export var min_time_to_wait : float = 1.4

# @export var chance_to_change_search_area : float = 0.08

# @export_subgroup("Fighting Parameters")
# var is_in_attack_range    : bool = false

# @export var weapon_attatchment : Node3D
# @export var attack_distance    : float = 5.0

@export_group("NPC Rendering")
@onready var mesh_pivot_ref = $MeshPivot
var is_in_frustum : bool = true


func mod_by_age() -> float:
	return minf(maxf((-sin(current_age / 31.85) * log(current_age / 100.0)) + 0.05, 0.5), 1.0)

func get_walk_speed() -> float:
	return base_move_speed * mod_by_age()

func get_run_speed() -> float:
	return get_walk_speed() * base_run_multiplier

func get_speed() -> float:
	return get_run_speed() if is_running else get_walk_speed()


func _ready() -> void:
	add_to_group("persist")

	get_node("AnimationHandler").caller_prefix = "NPC/"
	get_node("AnimationHandler").connect("attack_ended", _on_animation_handler_attack_ended)

	personality = get_node("Personality")
	scheduler = get_tree().get_root().get_node("Main/Scheduler")
	id = scheduler.request_id()
	process_group = scheduler.request_group()

	viewport = get_viewport()

	# weapon_attatchment = $"MeshPivot/Low-Poly-Base_blend/rig/Skeleton3D/BoneAttachment3D"

	should_attack_move = true
	navigation_agent.debug_enabled = true


func _process(delta: float) -> void:
	if not navigation_agent.is_navigation_finished() and last_position.distance_squared_to(self.global_position) <= last_position.distance_squared_to(last_position + (-mesh_pivot_ref.global_basis.z * get_speed() * delta)):
		stuck_timer += delta
		if stuck_timer >= max_stuck_time:
			npc_brain.reset_brain()
			stuck_timer = 0.0
	else:
		stuck_timer = 0.0

	last_position = self.global_position

# 	if thoughts_label != null:
# 		thoughts_label.text = State.find_key(_current_state) + "\n" + CombatState.find_key(current_combat_state)
# 		var new_label_position = viewport.get_camera_3d().unproject_position(label_anchor.global_transform.origin)
# 		new_label_position *= viewport.get_parent().stretch_shrink
# 		new_label_position = Vector2(new_label_position.x - (thoughts_label.size.x / 2.0), new_label_position.y - (thoughts_label.size.y / 2.0))
# 		thoughts_label.position = new_label_position

func _physics_process(delta: float) -> void:
	print(mesh.visible)
	if is_dead:
		return

	if not navigation_agent.is_navigation_finished():
		if look_target < Vector3.INF:
			look_direction = self.global_position.direction_to(look_target)
		else:
			look_direction = velocity.normalized()
		mesh_pivot_ref.rotation.y = lerp_angle(mesh_pivot_ref.rotation.y, atan2(-look_direction.x, -look_direction.z), delta * 10.0)

	if is_in_frustum:
		mesh_pivot_ref.visible = true
		if npc_brain.get_current_state() == NPCBrain.State.DEAD:
			pass
		elif not Vector2(velocity.x, velocity.z).is_zero_approx():
			if is_running:
				running.emit()
			else:
				walking.emit()
		else:
			idling.emit()
	else:
		mesh_pivot_ref.visible = false # CHANGE TO FADE WHEN POSSIBLE

	move_and_slide()

	if navigation_agent.is_navigation_finished():
		velocity = Vector3.ZERO

func handle_navigation(target_position : Vector3, look_target_position : Vector3, run : bool):
	var desired_velocity = Vector3.ZERO

	if should_attack_move == false or is_dead:
		return

	look_target = look_target_position

	if target_position.distance_to(self.global_position) < minimum_movement_distance:
		look_direction = self.global_position.direction_to(target_position)
		navigation_agent.target_position = self.global_position
		return

	navigation_agent.target_position = target_position

	is_running = run

	var current_agent_position: Vector3 = global_position
	var next_path_position: Vector3 = navigation_agent.get_next_path_position()
	desired_velocity = current_agent_position.direction_to(next_path_position) * get_speed()
	desired_velocity.y = -75.0
	navigation_agent.velocity = desired_velocity

func disable_pathfinding():
	navigation_agent.target_position = self.global_position
	velocity = Vector3.ZERO

func do_attack(attack_state : AnimationHandler.AnimationState, weapon : Weapon):
	super(attack_state, weapon)
	disable_pathfinding()
	var target_position : Vector3 = self.global_position + (-mesh_pivot_ref.global_basis.z * 100.0)
	handle_navigation(target_position, target_position, true)

func stop_attack_movement():
	super()
	disable_pathfinding()


func _on_navigation_finished() -> void:
	npc_brain.arrive_at_landmark_target()
	velocity = Vector3.ZERO

func _on_trigger_death() -> void:
	print("NPC died")
	# _current_state = State.DEAD
	is_dead = true
	death.emit()

func _on_navigation_agent_3d_velocity_computed(safe_velocity:Vector3) -> void:
	velocity = safe_velocity











# func __ready():
# 	add_to_group("persist")

# 	get_node("AnimationHandler").caller_prefix = "NPC/"
# 	get_node("AnimationHandler").connect("attack_ended", _on_animation_handler_attack_ended)

# 	personality = get_node("Personality")
# 	scheduler = get_tree().get_root().get_node("Main/Scheduler")
# 	id = scheduler.request_id()
# 	process_group = scheduler.request_group()

# 	scheduler.call_deferred("bind_callable_to_group", process_group, run_pathfinding_logic)

# 	calculate_average_poi_distance()

# 	if last_location == null:
# 		last_location = home

# 	chase_reset_base_time = (personality.mind * (1 - personality.aggression) / (personality.energy * personality.bravery))

# 	viewport = get_viewport()

# 	weapon_attatchment = $"MeshPivot/Low-Poly-Base_blend/rig/Skeleton3D/BoneAttachment3D"

# 	call_deferred("actor_setup") # Make sure to not await during _ready.

# func actor_setup():
# 	choose_target()
# 	await get_tree().physics_frame # Wait for the first physics frame so the NavigationServer can sync.
# 	if current_target == null:
# 		return
# 	set_movement_target(current_target.position) # Now that the navigation map is no longer empty, set the movement target.

# func set_movement_target(target_position : Vector3):
# 	if target_position == null:
# 		return

# 	navigation_agent.set_target_position(target_position)
# 	navigation_enabled = true

# func __process(delta: float) -> void:
# 	if _current_state == State.DEAD:
# 		return
# 	elif want_to_sleep and current_location == home:
# 		sleep_counter += delta
# 		_current_state = State.SLEEPING
# 		if sleep_counter >= sleep_amount_wanted:
# 			reset_sleep()
# 	elif not want_to_sleep and _current_state == State.MOVING_ABOUT:
# 		moving_about_time_this_day += delta
# 	else:
# 		awake_time_this_day += delta

# 	call_deferred("tick_timers", delta)

# 	call_deferred("tick_damage_taken", delta)

# 	## Checks if has attack target and if target list is empty
# 	if current_aggro_target != null and not damage_per_aggroer.is_empty():
# 		## Checks if cumulated damage is above threshold
# 		if damage_per_aggroer[current_aggro_target] >= damage_threshold:
# 			is_in_attack_range = self.position.distance_squared_to(current_aggro_target.position) <= attack_distance

# 			## Cheks if enemy is close enough for close combat or if should be chased
# 			_current_state = State.FIGHTING
# 			var is_allowed_state = current_combat_state not in [ CombatState.ATTACKING, CombatState.SEARCHING ]
# 			if not can_see_aggro_target:
# 				pass
# 			elif not is_in_attack_range and is_allowed_state:
# 				current_combat_state = CombatState.CHASING
# 				chase_reset_time = chase_reset_base_time + damage_per_aggroer[current_aggro_target]
# 				chase_reset_counter = chase_reset_time
# 			elif not is_attacking:
# 				current_combat_state = CombatState.CLOSE
# 				chase_reset_time = chase_reset_base_time + damage_per_aggroer[current_aggro_target]
# 				chase_reset_counter = chase_reset_time

# 	thoughts_label.text = State.find_key(_current_state) + "\n" + CombatState.find_key(current_combat_state)
# 	var new_label_position = viewport.get_camera_3d().unproject_position(label_anchor.global_transform.origin)
# 	new_label_position *= viewport.get_parent().stretch_shrink
# 	new_label_position = Vector2(new_label_position.x - (thoughts_label.size.x / 2.0), new_label_position.y - (thoughts_label.size.y / 2.0))
# 	thoughts_label.position = new_label_position

# func __physics_process(delta):
# 	if _current_state == State.DEAD:
# 		return

# 	var attack_target_direction : Vector3 = Vector3.ZERO
# 	var path_direction : Vector3 = (navigation_agent.get_next_path_position() - position).normalized()
# 	var path_to_attack_target_angle : float = 0.0

# 	if current_aggro_target != null:
# 		attack_target_direction = self.position.direction_to(current_aggro_target.position).normalized()
# 		path_to_attack_target_angle = attack_target_direction.angle_to(path_direction)

# 	if _current_state == State.FIGHTING and path_to_attack_target_angle < follow_look_angle:
# 		look_direction = attack_target_direction
# 	else:
# 		look_direction = path_direction
# 	mesh_pivot_ref.rotation.y = lerp_angle(mesh_pivot_ref.rotation.y, atan2(-look_direction.x, -look_direction.z), delta * 20.0)

# 	if current_aggro_target != null:
# 		var space_state = get_world_3d().direct_space_state
# 		var query = PhysicsRayQueryParameters3D.create(look_origin.global_position, current_aggro_target.global_position, 1)
# 		var	result = space_state.intersect_ray(query)
# 		var is_in_field_of_view = (-mesh_pivot_ref.global_transform.basis.z).dot(attack_target_direction) > field_of_view
# 		var is_in_range = position.distance_to(current_aggro_target.position) < attack_distance

# 		can_see_aggro_target = result.collider == current_aggro_target and is_in_field_of_view or is_in_range

# 		is_running = position.distance_squared_to(current_aggro_target.position) > attack_distance
# 		is_running = is_running and can_see_aggro_target

# 	var is_allowed_state = current_combat_state in [CombatState.CHASING, CombatState.SEARCHING, CombatState.ATTACKING]
# 	if (current_location != current_target and current_target != null) or is_allowed_state:
# 		velocity.y = -10.0
# 		# position += velocity * delta
# 		move_and_slide()

# 	if is_in_frustum:
# 		if _current_state == State.DEAD:
# 			pass
# 		elif not velocity.is_zero_approx():
# 			if is_running:
# 				running.emit()
# 			else:
# 				walking.emit()
# 		else:
# 			idling.emit()

# func tick_timers(delta : float):
# 	for timer in timers:
# 		if _current_state != State.DOING_STUFF:
# 			continue
# 		timers[timer] += delta
# 		if has_worked_today:
# 			continue
# 		has_worked_today = job.has_worked_today(get_landmark_timer(job, true))

# 		# if _current_state == State.DOING_STUFF:
# 		# 	# print(timers[timer])
# 		# 	timers[timer] += delta
# 		# 	if not has_worked_today:
# 		# 		has_worked_today = job.has_worked_today(get_landmark_timer(job, true))

# func tick_damage_taken(delta: float):
# 	for entity in damage_per_aggroer:
# 		if entity == current_aggro_target:
# 			continue
# 		damage_per_aggroer[entity] -= delta * damage_drain_rate
# 		if damage_per_aggroer[entity] <= 0:
# 			damage_per_aggroer.erase(entity)

# func run_pathfinding_logic():
# 	if _current_state == State.DEAD:
# 		print("NPC is dead")
# 		current_target = null
# 		velocity = Vector3.ZERO
# 		navigation_enabled = false
# 		scheduler.call_deferred("unbind_callable_from_group", process_group, self.run_pathfinding_logic)
# 		return
# 	elif want_to_sleep and _current_state != State.FIGHTING:
# 		return

# 	var is_allowed_state = _current_state not in [State.DEAD, State.DOING_STUFF, State.FIGHTING]

# 	if (navigation_agent.is_navigation_finished() and navigation_enabled and is_allowed_state):
# 		print("Navigation finished")
# 		velocity = Vector3.ZERO
# 		navigation_enabled = false

# 		calculate_average_poi_distance()
# 		# add_visit()
# 		current_location = current_target
# 		_current_state = State.DOING_STUFF

# 		timers[current_location] = 0.0

# 		if current_location == job:
# 			pass
# 		elif current_location == home:
# 			if has_worked_today:
# 				want_to_sleep = ((work_time_this_day * 0.15) + moving_about_time_this_day + (awake_time_this_day / 2.0)) / scheduler.full_day_time > personality.mind * personality.energy
# 				sleep_amount_wanted = max(4.0 * scheduler.full_day_time / 24.0, min(7.0 * scheduler.full_day_time / 24.0, work_time_this_day + moving_about_time_this_day))
# 	elif _current_state == State.DOING_STUFF:
# 		check_for_path_while_doing_stuff()
# 	elif _current_state == State.MOVING_ABOUT:
# 		check_for_path_while_moving()
# 	elif _current_state == State.FIGHTING:
# 		handle_combat()

# 	if navigation_enabled:
# 		var current_agent_position: Vector3 = global_position
# 		var next_path_position: Vector3 = navigation_agent.get_next_path_position()

# 		velocity = current_agent_position.direction_to(next_path_position) * get_speed()

# func handle_combat():
# 	current_target = null

# 	if chase_reset_counter <= 0.0 or damage_per_aggroer[current_aggro_target] < damage_threshold:
# 		current_aggro_target = null
# 		_current_state = State.DOING_STUFF
# 		current_combat_state = CombatState.NONE
# 		chase_reset_counter = chase_reset_time
# 		return

# 	# if can_see_aggro_target and not is_in_attack_range:
# 	# 	current_combat_state = CombatState.CHASING
# 	# 	wants_to_look_around = false
# 	# 	chase_reset_counter = chase_reset_time

# 	match current_combat_state:
# 		CombatState.NONE:
# 			pass

# 		CombatState.SEARCHING:
# 			chase_reset_counter -= get_physics_process_delta_time() * scheduler.number_of_groups

# 			if navigation_agent.is_navigation_finished():
# 				var change_search_area : bool = randf() < chance_to_change_search_area
# 				if change_search_area:
# 					print("changed search area")
# 					search_area_position = global_position

# 				current_combat_state = CombatState.LOOKING
# 				wait_to_search_timer = randf_range(min_time_to_wait, max_time_to_wait)

# 		CombatState.LOOKING:
# 			chase_reset_counter -= get_physics_process_delta_time() * scheduler.number_of_groups

# 			velocity = Vector3.ZERO
# 			navigation_enabled = false

# 			if wait_to_search_timer <= 0.0:
# 				var search_pos_x = search_area_position.x + randf_range(-search_radius, search_radius)
# 				var search_pos_z = search_area_position.z + randf_range(-search_radius, search_radius)
# 				var search_position = Vector3(search_pos_x, search_area_position.y, search_pos_z)
# 				set_movement_target(search_position)
# 				current_combat_state = CombatState.SEARCHING
# 			else:
# 				wait_to_search_timer -= get_physics_process_delta_time() * scheduler.number_of_groups

# 		CombatState.CHASING:
# 			if can_see_aggro_target:
# 				set_movement_target(current_aggro_target.position)
# 			elif navigation_agent.is_navigation_finished():
# 				current_combat_state = CombatState.SEARCHING
# 				search_area_position = global_position

# 		CombatState.CLOSE:
# 			velocity = self.position.direction_to(current_aggro_target.position) * get_speed()
# 			navigation_enabled = false
# 			if can_see_aggro_target:
# 				current_combat_state = CombatState.ATTACKING
# 				do_attack(AnimationHandler.AnimationState.ATTACK_LEFT, weapon_attatchment.get_children()[0])

# 		CombatState.ATTACKING:
# 			if not should_attack_move:
# 				velocity = Vector3.ZERO
# 				pass
# 			else:
# 				velocity = self.position.direction_to(current_aggro_target.position) * get_speed()


# func check_for_path_while_doing_stuff():
# 	choose_target()
# 	if current_location == current_target:
# 		return

# 	if current_location == job:
# 		work_time_this_day = timers[current_location]
# 		has_worked_today = true

# 	timers.erase(current_location)
# 	set_movement_target(current_target.position)
# 	last_location = current_location
# 	_current_state = State.MOVING_ABOUT

# func check_for_path_while_moving():
# 	choose_target()
# 	if current_location == current_target:
# 		return

# 	set_movement_target(current_target.position)

# func time_to_get_to_target() -> float:
# 	return position.distance_to(current_target.position) / get_speed()

# func choose_target():
# 	if home == null or job == null:
# 		return
# 	if last_location == null:
# 		last_location = home

# 	var targets_to_choose : Dictionary

# 	var interference = 0.0
# 	if has_worked_today and scheduler.get_current_time() <= (scheduler.full_day_time * home.time_want_to_arrive / 24.0):
# 		interference = personality.bravery + personality.energy

# 	for landmark in points_of_interest:
# 		targets_to_choose[landmark] = landmark.get_npc_want(self, current_location == landmark, interference + generate_interference()) / sqrt(get_landmark_timer(landmark, false))

# 	targets_to_choose[home] = home.get_npc_want(self, current_location == home, generate_interference()) / sqrt(get_landmark_timer(home, false))
# 	targets_to_choose[job] = job.get_npc_want(self, has_worked_today, generate_interference()) / sqrt(get_landmark_timer(job, false))

# 	if _current_state == State.MOVING_ABOUT:
# 		targets_to_choose[last_location] /= 10.0

# 	current_target = targets_to_choose.keys()[0]
# 	for landmark in targets_to_choose:
# 		if targets_to_choose[landmark] > targets_to_choose[current_target]:
# 			current_target = landmark

# func generate_interference() -> float:
# 	return randf_range(0.0, 1.0) * min(0.3, personality.chaos * exp(-randf_range(0.0, 2.0)) / (sqrt(scheduler.full_day_time / 100)))

# func reset_has_worked_today():
# 	has_worked_today = false

# func reset_sleep():
# 	print("AWAKE | ", scheduler.get_current_time_24())
# 	want_to_sleep = false
# 	sleep_amount_wanted = 0.0
# 	sleep_counter = 0.0
# 	awake_time_this_day = 0.0
# 	_current_state = State.DOING_STUFF

# func get_visit_by_landmark(landmark : Landmark) -> int:
# 	for visit in visits:
# 		if visit.landmark == landmark:
# 			return visit.landmark.number_of_visits

# 	return 0

# func add_visit(visited_landmark : Landmark):
# 	if not visits.has(visited_landmark):
# 		visits[visited_landmark] = 1
# 	else:
# 		visits[visited_landmark] += 1

# func get_landmark_timer(landmark : Node3D, receive_zero : bool) -> float:
# 	if not timers.has(landmark):
# 		return 0.0 if receive_zero else 1.0

# 	return timers[landmark]

# func scan_for_new_landmarks():
# 	pass

# func calculate_average_poi_distance():
# 	if points_of_interest.size() <= 0:
# 		average_poi_distance = 0.0
# 		return

# 	for poi in points_of_interest:
# 		average_poi_distance += self.position.distance_to(poi.position)
# 	average_poi_distance /= points_of_interest.size()

# func _on_damage_taken(damage : int, new_attacker : Entity) -> void:
# 	# print("taking damage: ", damage, " from ", new_attacker)
# 	if damage_per_aggroer.has(new_attacker):
# 		damage_per_aggroer[new_attacker] += damage
# 	else:
# 		damage_per_aggroer[new_attacker] = damage

# 	if current_aggro_target == null:
# 		current_aggro_target = new_attacker
# 		return
# 	else:
# 		for attacker in damage_per_aggroer:
# 			if damage_per_aggroer[attacker] > damage_per_aggroer[current_aggro_target]:
# 				current_aggro_target = attacker
