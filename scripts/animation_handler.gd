extends Node3D

@onready var animator = $"../MeshPivot/Viking_Female/AnimationPlayer"

signal dash_ended

enum State {IDLE, WALK, RUN, DASH, ATTACK, HURT}
var current_state: State = State.IDLE
var wanted_state : State = State.IDLE

var there_is_animation_playing: bool = false
var animation_speed 		  : float = 1.0


func _on_player_idling():
	wanted_state = State.IDLE

func _on_player_walking():
	wanted_state = State.WALK

func _on_player_running():
	wanted_state = State.RUN

func _on_player_dashing(dash_time):
	wanted_state = State.DASH
	animation_speed = 1.0 / dash_time


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	check_wanted_state()
	play_animation()


func check_wanted_state():
	if current_state not in [State.IDLE, State.WALK, State.RUN]:
		pass
		if not there_is_animation_playing:
			current_state = wanted_state
	else:
		current_state = wanted_state
	


func play_animation():
	there_is_animation_playing = true
	
	match current_state:
		State.IDLE:
			animator.play("Idle", -1, 1.0, false)
		
		State.WALK:
			animator.play("Walk", -1, 1.0, false)
		
		State.RUN:
			animator.play("Run", -1, 1.0, false)
		
		State.DASH:
			animator.play("Roll", -1, animation_speed, false)


func _on_animation_player_animation_finished(anim_name):
	there_is_animation_playing = false
	
	if anim_name == "Roll":
		dash_ended.emit()
