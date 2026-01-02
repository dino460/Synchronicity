extends Node

class_name AnimationHandler

@export var animator : AnimationPlayer
@export var animate_entity : Node

signal dash_ended
signal attack_ended
signal enable_combo

# Attack names refer the direction of the attack, or where the attack ends
# So, for example, an ATTACK_UP starts down and arcs upwards,
# while and ATTACK_LEFT starts on the right side and ends on the left
enum AnimationState {IDLE, WALK, RUN, DASH, ATTACK_UP, ATTACK_DOWN, ATTACK_LEFT, ATTACK_RIGHT, HURT, DEAD}
var current_state : AnimationState = AnimationState.IDLE
var wanted_state  : AnimationState = AnimationState.IDLE

var caller_prefix              : String = ""
var there_is_animation_playing : bool  = false
var is_attacking               : bool  = false
var on_combo                   : bool  = false

var last_attack_state : AnimationState;

var attack_states = [
	AnimationState.ATTACK_UP,
	AnimationState.ATTACK_DOWN,
	AnimationState.ATTACK_LEFT,
	AnimationState.ATTACK_RIGHT
]


func _ready() -> void:
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
	play_animation("idle", 3.0)

func _on_walking():
	wanted_state = AnimationState.WALK
	check_wanted_state()
	play_animation("walk", 3.8)

func _on_running():
	wanted_state = AnimationState.RUN
	check_wanted_state()
	play_animation("run", 8.0)

func _on_dashing(dash_time):
	wanted_state = AnimationState.DASH
	# animation_speed = 1.0 / dash_time
	check_wanted_state()
#	play_animation("dash")

func _on_death() -> void:
	current_state = AnimationState.DEAD
	wanted_state = AnimationState.DEAD
	is_attacking = false
	play_animation("death", 1.0)

func _on_attack(animation_direction: AnimationState, weapon: Weapon, was_attacking):
	wanted_state = animation_direction
	on_combo = was_attacking
	if check_wanted_state():
		last_attack_state = wanted_state
	play_animation(weapon.attack_animations[wanted_state], 5.5)


func check_wanted_state() -> bool:
	# var check_for_anim_interrupt := current_state not in interruptable_states and there_is_animation_playing
	var check_for_attack_interrupt := current_state in attack_states and is_attacking

	if check_for_attack_interrupt:
		return false
	elif current_state == AnimationState.DEAD:
		return false
	else:
		current_state = wanted_state
		return true

func play_animation(animation_name : String = "", animation_speed : float = 1.0):
	there_is_animation_playing = true
	animation_name = caller_prefix + animation_name

	if is_attacking:
		return
	elif current_state in attack_states:
		is_attacking = true
		animator.stop()
	else:
		is_attacking = false

	animator.play(animation_name, 0.1, animation_speed, false)


func end_attack():
	is_attacking = false
	attack_ended.emit()
	check_wanted_state()


func _on_animation_player_animation_finished(anim_name):
	there_is_animation_playing = false

	if anim_name == "Roll":
		dash_ended.emit()
