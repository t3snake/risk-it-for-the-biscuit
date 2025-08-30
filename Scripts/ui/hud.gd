extends CanvasLayer

@export var hint_enabled : bool
@export var hint_text : String

func _ready() -> void:
	%Level.text = "Level %d" % GlobalState.current_level
	
	if hint_enabled:
		%HintBackground.show()
		%HintText.text = "Hint: %s" % hint_text
	else:
		%HintBackground.hide()

func update_time_elapsed(time: float):
	%TimeElapsed.text = "Time elapsed: %.2f s" % time

func _on_hud_update_timer_timeout() -> void:
	update_time_elapsed(GlobalState.timer)

func _on_hint_disappear_timer_timeout() -> void:
	if hint_enabled:
		%HintBackground.hide()
