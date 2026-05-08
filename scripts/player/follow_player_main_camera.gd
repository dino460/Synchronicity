extends Camera3D

@export var player : Node3D
var camera_to_follow : Node3D

func _ready() -> void:
	camera_to_follow = player.find_child("EnvironmentCamera3D")

func _process(_delta: float) -> void:
	self.global_transform = camera_to_follow.global_transform
