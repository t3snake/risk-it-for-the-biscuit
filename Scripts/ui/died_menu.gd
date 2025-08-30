extends CanvasLayer


var current_level

func _ready() -> void:
	current_level = GameState.current_level
	
	var high_score = GameState.highscore_map[current_level - 1]
	%BestClearTime.text = "Best Clear Time: %.2f seconds" % high_score

func _on_restart_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/levels/level" + str(current_level) + ".tscn")

func _on_main_menu_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/ui/main_menu.tscn")
