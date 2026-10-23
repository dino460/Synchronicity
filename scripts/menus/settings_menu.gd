extends Node


@export var grass_density_menu : OptionButton

@export var next_scene : String


func _ready() -> void:
	for value in GlobalSettings.GrassDensity.values():
		var item_label : String = GlobalSettings.GrassDensity.find_key(value)
		grass_density_menu.add_item(item_label.capitalize())
	grass_density_menu.selected = GlobalSettings.GrassDensity.values().find(GlobalSettings.grass_density)


func _on_grass_density_option_button_item_selected(index: int) -> void:
	GlobalSettings.grass_density = GlobalSettings.GrassDensity.values()[index] as GlobalSettings.GrassDensity


func _on_reload_scene_button_pressed() -> void:
	get_tree().reload_current_scene()


func _on_change_scene_button_pressed() -> void:
	get_tree().change_scene_to_file(str("scenes/", next_scene, ".tscn"))
