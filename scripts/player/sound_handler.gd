extends Node

class_name SoundHandler

@export var audio_stream_player : AudioStreamPlayer3D

var step_sound = preload("res://sounds/151229__owlstorm__grassy-footstep-2.wav")

func play_step_sound():
	audio_stream_player.stream = step_sound
	audio_stream_player.play()
