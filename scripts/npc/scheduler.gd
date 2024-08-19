extends Timer

@export var full_day_time : int = 600
@export var sun_up_time_proportion : float = 0.5

@export var is_sun_up : bool = false


func _ready() -> void:
	is_sun_up = true
	wait_time = full_day_time
	start()

func _process(_delta: float) -> void:
	if time_left <= (full_day_time * sun_up_time_proportion):
		is_sun_up = false
	
	if is_stopped():
		is_sun_up = true
		start()
