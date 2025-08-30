extends CanvasLayer


func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	
	var current_level = GlobalState.current_level
	var high_score = GlobalState.highscore_map[current_level - 1]
	%BestClearTime.text = "Best Clear Time: %.2f s" % high_score

func _on_restart_button_pressed() -> void:
	GlobalState.restart_level()

func _on_main_menu_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/ui/main_menu.tscn")
