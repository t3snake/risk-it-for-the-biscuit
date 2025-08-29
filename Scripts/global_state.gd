extends Node

var timer: float
var is_timer_active: bool

var total_levels: int = 3
var levels_cleared: int
var current_level: int

var is_current_level_cleared : bool

var highscore_map: Dictionary

var kbm_active: bool

func _ready() -> void:
	levels_cleared = 0
	timer = 0
	is_timer_active = false
	
	highscore_map = {}
	for lvl in range(total_levels):
		highscore_map[lvl] = 0

# Core functions
func init_level(level: int) -> void:
	current_level = level
	timer = 0
	is_timer_active = false
	
	is_current_level_cleared = false

func set_level_cleared(level: int) -> void:
	if level > levels_cleared:
		levels_cleared = level
	
	is_current_level_cleared = true
	
	if highscore_map[level - 1] == 0:
		highscore_map[level - 1] = timer
	elif timer < highscore_map[level - 1]:
		highscore_map[level - 1] = timer
	
	timer = 0

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
