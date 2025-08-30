extends CanvasLayer


func _on_play_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/levels/level1.tscn")

func _on_level_select_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/ui/level_select_menu.tscn")

func _on_quit_button_pressed() -> void:
	get_tree().quit()
