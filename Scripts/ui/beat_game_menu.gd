extends CanvasLayer


func _on_main_menu_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/ui/main_menu.tscn")
