extends SubViewportContainer

func _ready() -> void:
	change_pixelation_by_resolution()
	pass

func change_pixelation_by_resolution():
	var current_res = mini(DisplayServer.window_get_size().x, DisplayServer.window_get_size().y)
	
	stretch_shrink = max(5, 5 * current_res / 1080)
	
	print(current_res, " ", stretch_shrink)
	pass
