extends CharacterBody3D

class_name MainCharacter

# references
@onready var spring_arm = $SpringArm3D # camera arm
@onready var camera = $SpringArm3D/Camera3D
@onready var anim_player = $CharacterModel/AnimationPlayer
@onready var model = $CharacterModel

# editor exported state
@export_group("Player Parameters")
@export var speed = 10.0
@export var acceleration = 10.0

@export var high_jump_vert_speed = 18.0
@export var long_jump_vert_speed = 12.0
@export var dive_vert_speed = 8.0

# 24m horizontal distance possible with 12.0 y and 20 horizontal (long jump)
@export_group("Mouse")
@export var mouse_sensitivity = 0.0015
@export var rotation_speed = 15.0

@export var killzone_y = -10.0

# debug params
@export_group("Debug")
@export var show_debug_info = true

enum CharacterState { IDLE, WALK, RUN, JUMP, FALL, DIVE }
enum JumpState { LONG_JUMP, NORMAL_JUMP, BACKFLIP }

# state
var input = Vector2.ZERO
var character_state : CharacterState
var jump_state : JumpState

var is_running : bool
var is_jumping : bool
var is_falling : bool # to play fall animation after jump
var is_diving : bool
var dive_direction_y = 0.0 # to save direction on diving to lerp to later

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity") * 3

func _ready() -> void:
	#GlobalState.initialize_level()
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
	jump_state = JumpState.NORMAL_JUMP
	character_state = CharacterState.IDLE
	
	is_running = false
	is_diving = false
	is_falling = false
	is_jumping = false

func _physics_process(delta):
	if global_position.y < killzone_y:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		game_over()
	
	velocity.y += -gravity * delta
	if !is_jumping:
		get_move_input(delta)
	move_and_slide()
	
	set_character_state()
	handle_animation()
	
	if !input.is_zero_approx() and !is_jumping:
		model.rotation.y = lerp_angle(model.rotation.y, spring_arm.rotation.y, rotation_speed * delta)
	elif is_diving:
		model.rotation.y = lerp_angle(model.rotation.y, dive_direction_y, rotation_speed * delta)
	
	# Debug info
	if is_jumping and absf(velocity.y) < 0.25 and show_debug_info:
		if is_diving:
			print("Dive Jump")
		elif jump_state == JumpState.NORMAL_JUMP:
			print("Normal Jump")
		elif jump_state == JumpState.LONG_JUMP:
			print("Long Jump")
		var horiz_speed = Vector2(velocity.x, velocity.z)
		print("Horizontal speed: " + str(horiz_speed.length()))
		print("Vertical height: " + str(global_position.y))

func get_move_input(delta):
	var vy = velocity.y
	velocity.y = 0
	input = Input.get_vector("left", "right", "forward", "back")
	var dir = Vector3(input.x, 0, input.y)
	if spring_arm:
		dir = dir.rotated(Vector3.UP, spring_arm.rotation.y)
	var new_speed = speed*2 if is_running else speed
	velocity = lerp(velocity, dir * new_speed, acceleration * delta)
	velocity.y = vy

func _unhandled_input(event):
	if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		if event is InputEventMouseMotion:
			# camera handling on mouse movement
			spring_arm.rotation.x -= event.relative.y * mouse_sensitivity
			spring_arm.rotation_degrees.x = clamp(spring_arm.rotation_degrees.x, -90.0, 30.0)
			spring_arm.rotation.y -= event.relative.x * mouse_sensitivity

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	
	if event.is_action_pressed("click"):
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
	if event.is_action_pressed("jump"):
		if !is_jumping and is_on_floor():
			is_jumping = true
			if is_running:
				# long jump
				velocity.y = long_jump_vert_speed
				jump_state = JumpState.LONG_JUMP
			else:
				# high jump
				velocity.y = high_jump_vert_speed
				jump_state = JumpState.NORMAL_JUMP
		elif (is_jumping and !is_diving) or (is_falling and !is_diving):
			is_diving = true
			var dive_velocity = get_dive_velocity()
			# if dive in the opposite direction, the magnitude is same as initial jump
			# if in same direction, the magnitude increases by 50%
			if dive_velocity.dot(velocity) > 0:
				velocity = 1.5 * dive_velocity
			else:
				velocity = dive_velocity
	
	if event.is_action_pressed("run"):
		is_running = true
	
	if event.is_action_released("run"):
		is_running = false

func get_dive_velocity():
	var cam_dir = -camera.get_global_transform().basis.z
	var cam_horizontal_dir = Vector2(cam_dir.x, cam_dir.z).normalized()
	var player_horizontal_speed = Vector2(velocity.x, velocity.z).length()
	var dive_horizontal_velocity = cam_horizontal_dir * player_horizontal_speed
	dive_direction_y = spring_arm.rotation.y
	
	return Vector3(
		dive_horizontal_velocity.x,
		dive_vert_speed,
		dive_horizontal_velocity.y
	)

func set_character_state():
	if !is_falling and velocity.y < -2:
		is_falling = true
		
	if is_on_floor():
		is_jumping = false
		is_falling = false
		is_diving = false
	
	if is_diving:
		character_state = CharacterState.DIVE
	elif is_falling:
		character_state = CharacterState.FALL
	elif is_jumping:
		character_state = CharacterState.JUMP
	elif is_running and !input.is_zero_approx():
		character_state = CharacterState.RUN
	elif input.is_zero_approx():
		character_state = CharacterState.IDLE
	else:
		character_state = CharacterState.WALK

func handle_animation():
	match character_state:
		CharacterState.WALK:
			play_animation("walk")
		CharacterState.RUN:
			play_animation("sprint")
		CharacterState.IDLE:
			play_animation("idle")
		CharacterState.JUMP:
			play_animation("jump")
		CharacterState.FALL:
			play_animation("fall")
		CharacterState.DIVE:
			play_animation("drive")

func play_animation(anim_name: String) -> void:
	if anim_player.is_playing() and anim_player.current_animation == anim_name:
		return
	
	anim_player.play(anim_name)

func register_hit() -> void:
	# TODO death? health?
	pass

#func _on_hit_area_body_entered(body: Node3D) -> void:
	#if body is Zombie:
		#var dir = body.global_position - self.global_position
		#body.register_hit(Vector2(dir.x, dir.z))

func game_over() -> void:
	spring_arm.top_level = true;
	await get_tree().create_timer(1).timeout
	get_tree().change_scene_to_file("res://Scenes/world.tscn")
