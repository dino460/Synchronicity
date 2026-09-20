extends Camera3D

@export var player : Node3D
var player_camera : Camera3D

func _ready() -> void:
	player_camera = player.find_child("EnvironmentCamera3D")
	self.attributes = player_camera.attributes

func _process(delta: float) -> void:
	self.position = player_camera.position
	self.rotation = player_camera.rotation
