extends Node3D

var animator : AnimationPlayer

func _ready() -> void:
	animator = get_node("AnimationPlayer")

func _process(_delta: float) -> void:
	if animator.animation_finished:
		animator.play("attack", 0.1, 5.5)
