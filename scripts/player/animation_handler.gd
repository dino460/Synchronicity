extends Node

class_name AnimationHandler

@export var animator : AnimationPlayer
@export var animate_entity : Node

signal dash_ended
signal attack_started(stance : AttackStances)
signal attack_ended
signal spend_stamina(stamina_cost : float)
# signal enable_combo

# Attack names refer the direction of the attack, or where the attack ends
# So, for example, an ATTACK_UP starts down and arcs upwards,
# while and ATTACK_LEFT starts on the right side and ends on the left
enum AnimationState {IDLE, WALK, RUN, DASH, ATTACK_UP, ATTACK_DOWN, ATTACK_LEFT, ATTACK_RIGHT, HURT, DEAD}
var anim_states_keys : Array = AnimationState.keys()
var current_state : AnimationState = AnimationState.IDLE
var wanted_state  : AnimationState = AnimationState.IDLE

var caller_prefix              : String = ""
var there_is_animation_playing : bool  = false
var is_attacking               : bool  = false
var can_combo                  : bool  = false

var last_attack_state : AnimationState;

var attack_states = [
	AnimationState.ATTACK_UP,
	AnimationState.ATTACK_DOWN,
	AnimationState.ATTACK_LEFT,
	AnimationState.ATTACK_RIGHT
]

enum AttackStances {NONE, ROOF, PLOW, FOOL, TWOHORN}
var stances_keys : Array = AttackStances.keys()
var current_stance : AttackStances = AttackStances.NONE

@export var weapon_holder : Node3D

@export var hand : Node3D
@export var sheathe : Node3D

@export var stats : CharacterStats

var anim_name : String = ""


func _ready() -> void:
	print(weapon_holder.transform)
	if animator == null:
		animator = animate_entity.get_node("AnimationPlayer")
	remove_animation_interpolation()

func remove_animation_interpolation():
	for anim in animator.get_animation_list():
		for track in animator.get_animation(anim).get_track_count():
			animator.get_animation(anim).track_set_interpolation_type(track, Animation.INTERPOLATION_NEAREST)

func _on_idling():
	wanted_state = AnimationState.IDLE
	check_wanted_state()
	# play_animation("idle", 3.0)
	# play_animation("idle_plow_lswrd", 1.0 + (stats.exhaustion / stats.max_exhaustion))
	anim_name = "idle"
	if current_stance != AttackStances.NONE:
		anim_name += "_" + stances_keys[current_stance].to_lower() + "_" + weapon_holder.get_child(0).get_type_string().to_lower()
	play_animation(anim_name, 0.1, 1.0 + (stats.exhaustion / stats.max_exhaustion))

func _on_walking():
	wanted_state = AnimationState.WALK
	check_wanted_state()
	# play_animation("walk", 3.8)
	# play_animation("walk_plow_lswrd", 1.0)
	anim_name = "walk"
	if current_stance != AttackStances.NONE:
		anim_name += "_" + stances_keys[current_stance].to_lower() + "_" + weapon_holder.get_child(0).get_type_string().to_lower()
	play_animation(anim_name)

func _on_running():
	wanted_state = AnimationState.RUN
	check_wanted_state()
	# play_animation("run", 8.0)
	# play_animation("run_slgswrd", 1.0)
	anim_name = "run"
	if current_stance != AttackStances.NONE:
		anim_name += "_" + weapon_holder.get_child(0).get_group_string().to_lower()
	play_animation(anim_name)

func _on_dashing(dash_time):
	wanted_state = AnimationState.DASH
	# animation_speed = 1.0 / dash_time
	check_wanted_state()
#	play_animation("dash")

func _on_death() -> void:
	current_state = AnimationState.DEAD
	wanted_state = AnimationState.DEAD
	is_attacking = false
	play_animation("death")

func _on_attack(animation_direction: AnimationState, current_stamina):
	if current_stance == AttackStances.NONE:
		return
	if current_stamina < weapon_holder.get_child(0).stamina_cost_per_stance[current_stance]:
		print("fumble")
		return
	wanted_state = animation_direction
	if check_wanted_state():
		last_attack_state = wanted_state
	# play_animation(weapon.attack_animations[wanted_state], 5.5)

		anim_name = anim_states_keys[wanted_state].right(-7).to_lower()
		anim_name += "_" + stances_keys[current_stance].to_lower()
		anim_name += "_" + weapon_holder.get_child(0).get_type_string().to_lower()
		play_animation(anim_name, 0.1)
		can_combo = false


func check_wanted_state() -> bool:
	# var check_for_anim_interrupt := current_state not in interruptable_states and there_is_animation_playing
	var check_for_attack_interrupt := current_state in attack_states and is_attacking and not can_combo

	if check_for_attack_interrupt or current_state == AnimationState.DEAD or (wanted_state in attack_states and current_stance == AttackStances.NONE):
		return false
	else:
		current_state = wanted_state
		return true

func play_animation(animation_name : String = "", transition_time : float = 0.1, animation_speed : float = 1.0):
	there_is_animation_playing = true
	animation_name = caller_prefix + animation_name

	if is_attacking and not can_combo:
		return
	elif current_state in attack_states:
		is_attacking = true
		animator.stop()
	else:
		is_attacking = false

	animator.play(animation_name, transition_time, animation_speed, false)


func start_attack():
	attack_started.emit(current_stance)

func end_attack():
	is_attacking = false
	attack_ended.emit()
	# if current_stance == AttackStances.ROOF and current_state == AnimationState.ATTACK_DOWN:
	# 	current_stance = AttackStances.FOOL
	check_wanted_state()

func enable_combo():
	can_combo = true

func signal_stamina_use():
	spend_stamina.emit(weapon_holder.get_child(0).stamina_cost_per_stance[current_stance])


func _on_animation_player_animation_finished(anim_name):
	there_is_animation_playing = false

	if anim_name == "Roll":
		dash_ended.emit()


func _on_input_handler_stance(stance_val: int) -> void:
	if current_state == AnimationState.RUN:
		return
	current_stance = stance_val as AttackStances
	change_weapon_position()

func _on_input_handler_increase_stance() -> void:
	if current_state == AnimationState.RUN:
		return
	var stance : int = current_stance as int
	stance += 1
	if stance >= AttackStances.size():
		current_stance = 0 as AttackStances
	else:
		current_stance = stance as AttackStances
	change_weapon_position()

func _on_input_handler_decrease_stance() -> void:
	if current_state == AnimationState.RUN:
		return
	var stance : int = current_stance as int
	stance -= 1
	if stance < 0:
		current_stance = AttackStances.size() - 1 as AttackStances
	else:
		current_stance = stance as AttackStances
	change_weapon_position()

func change_weapon_position():
	if current_stance == AttackStances.NONE and sheathe.get_child_count() == 0:
		weapon_holder.reparent(sheathe)
		weapon_holder.transform = weapon_holder.get_child(0).weapon_sheathe_transform
		print(weapon_holder.transform)
	elif current_stance != AttackStances.NONE and hand.get_child_count() == 0:
		weapon_holder.reparent(hand)
		weapon_holder.transform = weapon_holder.get_child(0).weapon_hand_transform
		print(weapon_holder.transform)

	pass
# 0,806 0,246 3,613
# -35,4 -99,7 98,7
#
# 0,319 0,598 -1,647
# 16,9 -97,5 -89,9

# HAND : [X: (0.287765, -0.956843, 0.04052), Y: (-0.13204, 0.002266, 0.991242), Z: (-0.948555, -0.290595, -0.125689), O: (0.318746, 0.597563, -1.646948)]
# HIP: [X: (0.589915, 0.805749, -0.052619), Y: (0.080181, -0.123297, -0.989125), Z: (-0.803474, 0.579281, -0.13734), O: (0.806, 0.246, 3.613)]
