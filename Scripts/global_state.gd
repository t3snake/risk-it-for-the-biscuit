extends Node

var timer: float
var is_timer_active: bool

# global state
var total_levels: int = 6
var levels_cleared: int
# TODO this could be array since key is level
var highscore_map: Dictionary
var bonus_time_map: Array  # in seconds

# current state
var current_level: int
var is_current_level_cleared : bool

var kbm_active: bool

func _ready() -> void:
	levels_cleared = 0
	timer = 0
	is_timer_active = false
	
	highscore_map = {}
	bonus_time_map = [3, 3, 3, 4, 4, 5]
	for lvl in range(total_levels):
		highscore_map[lvl] = 0

# Core functions
func init_level(level: int) -> void:
	current_level = level
	timer = 0
	is_timer_active = false
	
	is_current_level_cleared = false

func set_level_cleared() -> void:
	if current_level > levels_cleared:
		levels_cleared = current_level
	
	is_current_level_cleared = true
	
	if highscore_map[current_level - 1] == 0:
		highscore_map[current_level - 1] = timer
	elif timer < highscore_map[current_level - 1]:
		highscore_map[current_level - 1] = timer

func go_to_next_level() -> void:
	if current_level < total_levels:
		get_tree().change_scene_to_file(
			"res://Scenes/level%d.tscn" % (current_level + 1)
		)
	else:
		get_tree().change_scene_to_file("res://Scenes/ui/beat_game_menu.tscn")

func restart_level() -> void:
	get_tree().change_scene_to_file("res://Scenes/level%d.tscn" % current_level)

func _process(delta: float) -> void:
	if is_timer_active:
		timer += delta

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion or event is InputEventKey:
		kbm_active = true
	elif event is InputEventJoypadButton or event is InputEventJoypadMotion:
		kbm_active = false

# Timer functions

func start_timer() -> void:
	is_timer_active = true
	timer = 0

func unpause_timer() -> void:
	is_timer_active = true

func stop_timer() -> void:
	is_timer_active = false
