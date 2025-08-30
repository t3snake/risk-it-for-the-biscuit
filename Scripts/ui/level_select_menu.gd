extends CanvasLayer

@onready var level_1_high_score := $TextureRect/MarginContainer/HBoxContainer/VBoxContainer2/Level1HighScore
@onready var level_2_high_score := $TextureRect/MarginContainer/HBoxContainer/VBoxContainer2/Level2HighScore
@onready var level_3_high_score := $TextureRect/MarginContainer/HBoxContainer/VBoxContainer2/Level3HighScore

func _ready() -> void:
	var template := "High Score: %.2f s"
	var no_score := "High Score: NA"
	
	var level_1_score = GameState.highscore_map[0]
	if level_1_score != 0:
		level_1_high_score.text = template % level_1_score
	else:
		level_1_high_score.text = no_score
		
	var level_2_score = GameState.highscore_map[1]
	if level_2_score != 0:
		level_2_high_score.text = template % level_2_score
	else:
		level_2_high_score.text = no_score
		
	var level_3_score = GameState.highscore_map[2]
	if level_3_score != 0:
		level_3_high_score.text = template % level_3_score
	else:
		level_3_high_score.text = no_score


func _on_level_1_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/levels/level1.tscn")


func _on_level_2_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/levels/level2.tscn")


func _on_level_3_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/levels/level3.tscn")
