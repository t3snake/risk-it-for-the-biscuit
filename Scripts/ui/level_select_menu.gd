extends CanvasLayer


func _ready() -> void:
	var template := "High Score: %.2f s"
	var no_score := "High Score: NA"
	
	var level_label_arr = [
		%Level1HighScore,
		%Level2HighScore,
		%Level3HighScore,
		%Level4HighScore,
		%Level5HighScore,
		%Level6HighScore
	]
	
	# populate highscore for each level
	for i in range(GlobalState.total_levels):
		var level_score = GlobalState.highscore_map[i]
		if level_score != 0:
			level_label_arr[i].text = template % level_score
		else:
			level_label_arr[i].text = no_score

func _on_level_1_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/level1.tscn")

func _on_level_2_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/level2.tscn")

func _on_level_3_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/level3.tscn")

func _on_level_4_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/level4.tscn")

func _on_level_5_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/level5.tscn")

func _on_level_6_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/level6.tscn")
