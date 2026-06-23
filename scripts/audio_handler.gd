extends Node3D

@export var weapon_holder : Node3D

@export var footstep_player : AudioStreamPlayer3D
@export var attack_player : AudioStreamPlayer3D

@export var footsteps_sounds : Array[AudioStream]
@export var sword_swing_sounds : Array[AudioStream]


func play_walkstep():
	footstep_player.volume_db = 1.0
	footstep_player.stream = footsteps_sounds[randi_range(0, footsteps_sounds.size()-1)]
	footstep_player.pitch_scale = randf_range(0.8, 1.2)
	footstep_player.play()

func play_runstep():
	footstep_player.volume_db = 3.0
	footstep_player.stream = footsteps_sounds[randi_range(0, footsteps_sounds.size()-1)]
	footstep_player.pitch_scale = randf_range(0.5, 0.7)
	footstep_player.play()

func play_attack():
	attack_player.volume_db = 0.0
	attack_player.stream = weapon_holder.get_child(0).attack_sounds[randi_range(0, weapon_holder.get_child(0).attack_sounds.size()-1)]
	attack_player.pitch_scale = randf_range(0.8, 1.2)
	attack_player.play()
