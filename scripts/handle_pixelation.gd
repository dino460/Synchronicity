extends SubViewportContainer

func _ready() -> void:
	get_viewport().connect("size_changed", _change_pixelation_by_resolution)
	_change_pixelation_by_resolution()
	pass

func _change_pixelation_by_resolution():
	var current_res = mini(DisplayServer.window_get_size().x, DisplayServer.window_get_size().y)

	stretch_shrink = max(5, 5 * current_res / 1080)

	print(current_res, " ", stretch_shrink)
	pass
