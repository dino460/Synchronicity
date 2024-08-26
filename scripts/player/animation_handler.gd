extends Node

@onready var animator = $"../MeshPivot/Low-Poly-Base_blend/AnimationPlayer"


signal dash_ended
signal attack_ended
signal can_combo

enum State {IDLE, WALK, RUN, DASH, ATTACK_LIGHT, ATTACK_HEAVY, HURT}
var current_state : State = State.IDLE
var wanted_state  : State = State.IDLE

var there_is_animation_playing : bool  = false
var is_attacking               : bool  = false
var animation_speed            : float = 1.0
var combo_value                : int   = 0

var interruptable_states = [State.IDLE, State.WALK, State.RUN]


func _on_player_idling():
	wanted_state = State.IDLE
	animation_speed = 0.3
	check_wanted_state()
#	play_animation()

func _on_player_walking():
	wanted_state = State.WALK
	animation_speed = 5.0
	check_wanted_state()
	play_animation()

func _on_player_running():
	wanted_state = State.RUN
	animation_speed = 8.0
	check_wanted_state()
	play_animation()

func _on_player_dashing(dash_time):
	wanted_state = State.DASH
	animation_speed = 1.0 / dash_time
	check_wanted_state()
#	play_animation()

func _on_player_attack_light(weapon: Weapon, current_combo_value):
	wanted_state = State.ATTACK_LIGHT
	
#	current_weapon = weapon
	combo_value = current_combo_value
	animation_speed = 1.0 / weapon.light_attack_time
	check_wanted_state()
#	play_animation()


func check_wanted_state():
	if current_state not in interruptable_states:
		if not there_is_animation_playing:
			current_state = wanted_state
	else:
		current_state = wanted_state


func play_animation():
	there_is_animation_playing = true
#
	match current_state:
#		State.IDLE:
#			#animator.play("Idle", -1, 1.0, false)
#			next_animation_name = "idle_" + current_weapon.type
#
		State.WALK:
			animator.play("walk", -1, animation_speed, false)
#			next_animation_name = "walk_" + current_weapon.type
#
		State.RUN:
			animator.play("run", -1, animation_speed, false)
#			next_animation_name = "run_" + current_weapon.type
#
#		State.DASH:
#			#animator.play("Roll", -1, animation_speed, false)
#			next_animation_name = "roll_" + current_weapon.type
#
#		State.ATTACK_LIGHT:
#			if !is_attacking:
#				is_attacking = true
#				#animator.play(current_weapon.light_attack_animations[combo_value], -1, animation_speed, false)
#				next_animation_name = current_weapon.light_attack_animations[combo_value]
#
	#animator.play(next_animation_name, -1, animation_speed, false)


# Called on the end of an animation to enable chaining them into a combo
# DO NOT FORGET TO ADD THIS TO A METHOD TRACK
func enable_combo():
	is_attacking = false
	can_combo.emit()


func _on_animation_player_animation_finished(anim_name):
	there_is_animation_playing = false
	
	if anim_name == "Roll":
		dash_ended.emit()
#	elif anim_name in current_weapon.light_attack_animations or anim_name in current_weapon.heavy_attack_animations:
#		is_attacking = false
#		attack_ended.emit()


func _on_combo_cooldown_timer_timeout():
	combo_value = 0
