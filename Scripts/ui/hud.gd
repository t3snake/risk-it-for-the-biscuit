extends CanvasLayer

func update_time_elapsed(time: float):
	%TimeElapsed.text = "Time elapsed: %.2f s" % time
	
func update_enemies_remaining(count: int):
	%EnemiesRemaining.text = "Enemies remaining: %d" % count

func set_dash_on_cooldown():
	%Dash.add_theme_color_override("font_color", Color.GRAY)

func set_dash_ready():
	%Dash.add_theme_color_override("font_color", Color.BLACK)

func set_shotgun_on_cooldown():
	%Shotgun.add_theme_color_override("font_color", Color.GRAY)

func set_shotgun_ready():
	%Shotgun.add_theme_color_override("font_color", Color.BLACK)

func _on_hud_update_timer_timeout() -> void:
	update_time_elapsed(GlobalState.timer)
