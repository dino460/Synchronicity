extends Node

class_name AnimationHandler

@onready var animator = $"../MeshPivot/Low-Poly-Base_blend/AnimationPlayer"


signal dash_ended
signal attack_ended

# Attack names refer the direction of the attack, or where the attack ends
# So, for example, an ATTACK_UP starts down and arcs upwards,
# while and ATTACK_LEFT starts on the right side and ends on the left
enum AnimationState {IDLE, WALK, RUN, DASH, ATTACK_UP, ATTACK_DOWN, ATTACK_LEFT, ATTACK_RIGHT, HURT}
var current_state : AnimationState = AnimationState.IDLE
var wanted_state  : AnimationState = AnimationState.IDLE

var there_is_animation_playing : bool  = false
var is_attacking               : bool  = false
var on_combo                   : bool  = false
var animation_speed            : float = 1.0

var last_attack_state : AnimationState;

var interruptable_states = [AnimationState.IDLE, AnimationState.WALK, AnimationState.RUN]


func _ready() -> void:
	remove_animation_interpolation()

func remove_animation_interpolation():
	for anim in animator.get_animation_list():
		for track in animator.get_animation(anim).get_track_count():
			animator.get_animation(anim).track_set_interpolation_type(track, Animation.INTERPOLATION_NEAREST)


func _on_player_idling():
	wanted_state = AnimationState.IDLE
	animation_speed = 3.0
	check_wanted_state()
	play_animation()

func _on_player_walking():
	wanted_state = AnimationState.WALK
	animation_speed = 3.8
	check_wanted_state()
	play_animation()

func _on_player_running():
	wanted_state = AnimationState.RUN
	animation_speed = 8.0
	check_wanted_state()
	play_animation()

func _on_player_dashing(dash_time):
	wanted_state = AnimationState.DASH
	animation_speed = 1.0 / dash_time
	check_wanted_state()
#	play_animation()

func _on_player_attack(animation_direction: AnimationState, weapon: Weapon, was_attacking):
	wanted_state = animation_direction
	on_combo = was_attacking
#	current_weapon = weapon
	if check_wanted_state():
		if weapon.is_preferred_attack(last_attack_state, wanted_state):
			# Do something damage and animation speed related some day
			pass
		animation_speed = 8.0 #1.0 / weapon.up_attack_time
		last_attack_state = wanted_state
	play_animation(weapon.attack_animations[wanted_state])


func check_wanted_state() -> bool:
	if current_state not in interruptable_states:
		if not there_is_animation_playing:
			current_state = wanted_state
			return true
		else:
			return false
	else:
		current_state = wanted_state
		return true


func play_animation(animation_name : String = ""):
	there_is_animation_playing = true
#
	match current_state:
		AnimationState.IDLE:
			animator.play("idle", -1, animation_speed, false)
#			next_animation_name = "idle_" + current_weapon.type
#
		AnimationState.WALK:
			animator.play("walk", -1, animation_speed, false)
#			next_animation_name = "walk_" + current_weapon.type
#
		AnimationState.RUN:
			animator.play("run", -1, animation_speed, false)
#			next_animation_name = "run_" + current_weapon.type
#
#		AnimationState.DASH:
#			#animator.play("Roll", -1, animation_speed, false)
#			next_animation_name = "roll_" + current_weapon.type
#
		AnimationState.ATTACK_UP:
			if !is_attacking:
				is_attacking = true
				animator.play(animation_name, -1, animation_speed, false)
				# next_animation_name = current_weapon.light_attack_animations[combo_value]
#
	#animator.play(next_animation_name, -1, animation_speed, false)


# Called on the end of an animation to enable chaining them into a combo
# DO NOT FORGET TO ADD THIS TO A METHOD TRACK
func enable_combo():
	is_attacking = false


func _on_animation_player_animation_finished(anim_name):
	there_is_animation_playing = false

	if anim_name == "Roll":
		dash_ended.emit()
#	elif anim_name in current_weapon.light_attack_animations or anim_name in current_weapon.heavy_attack_animations:
#		is_attacking = false
#		attack_ended.emit()
