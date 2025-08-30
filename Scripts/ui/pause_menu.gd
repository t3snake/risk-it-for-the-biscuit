extends CanvasLayer

var level

func _ready() -> void:
	level = get_node("/root/Level")

func _on_resume_button_pressed() -> void:
	level.toggle_pause_menu()

func _on_restart_button_pressed() -> void:
	level.toggle_pause_menu()
	get_tree().reload_current_scene()

func _on_main_menu_button_pressed() -> void:
	level.toggle_pause_menu()
	get_tree().change_scene_to_file("res://scenes/ui/main_menu.tscn")
