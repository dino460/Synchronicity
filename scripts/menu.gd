extends Control



func _on_button_2_pressed() -> void:
	get_tree().quit()

func _on_button_pressed() -> void:
	self.visible = false
