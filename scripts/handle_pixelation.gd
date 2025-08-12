extends SubViewportContainer

var minimum_pixelation    : int
var pixelation_correction : int


func _ready() -> void:
	minimum_pixelation = GlobalSettings.minimum_pixelation
	pixelation_correction = GlobalSettings.pixelation_correction

	get_viewport().connect("size_changed", _change_pixelation_by_resolution)
	_change_pixelation_by_resolution()

func _change_pixelation_by_resolution():
	var current_res = mini(DisplayServer.window_get_size().x, DisplayServer.window_get_size().y)

	stretch_shrink = int(max(minimum_pixelation, pixelation_correction * current_res / 1080.0))
