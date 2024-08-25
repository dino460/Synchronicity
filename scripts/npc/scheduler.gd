extends Timer

@export var full_day_time : float = 600.0
@export var sun_up_time_proportion : float = 0.5

@export var is_sun_up : bool = false

@export var sun : DirectionalLight3D


func _ready() -> void:
	is_sun_up = true
	wait_time = full_day_time
	start()

func _process(_delta: float) -> void:
	is_sun_up = false if time_left <= (full_day_time * sun_up_time_proportion) else true
	
	rotate_sun()
	
	if is_stopped():
		start()
	
func rotate_sun():
	if sun != null:
		sun.rotation_degrees = Vector3(
			(time_left / full_day_time) * 360.0, 
			sun.rotation_degrees.y, 
			sun.rotation_degrees.z
		)
