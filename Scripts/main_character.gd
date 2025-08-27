extends CharacterBody3D

class_name MainCharacter

# references
@onready var spring_arm = $SpringArm3D # camera arm
@onready var anim_player = $CharacterModel/AnimationPlayer
@onready var model = $CharacterModel

# editor exported state
@export var speed = 10.0
@export var acceleration = 10.0

@export var high_jump_vert_speed = 18.0
@export var long_jump_vert_speed = 12.0

@export var mouse_sensitivity = 0.0015
@export var rotation_speed = 15.0

@export var killzone_y = -10.0

enum CharacterState { IDLE, WALK, RUN, JUMP, FALL }
enum JumpState { LONG_JUMP, NORMAL_JUMP, BACKFLIP }

# state
var input = Vector2.ZERO
var character_state : CharacterState
var jump_state : JumpState
var is_running : bool
var is_jumping : bool
var is_falling : bool # to play fall animation after jump

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity") * 3

func _ready() -> void:
	#GlobalState.initialize_level()
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
	jump_state = JumpState.NORMAL_JUMP
	character_state = CharacterState.IDLE
	
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	
	if event.is_action_pressed("click"):
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
	if event.is_action_pressed("jump") and !is_jumping:
		is_jumping = true
		if is_running:
			# long jump
			velocity.y = long_jump_vert_speed
			jump_state = JumpState.LONG_JUMP
		else:
			# high jump
			velocity.y = high_jump_vert_speed
			jump_state = JumpState.NORMAL_JUMP
	
	if event.is_action_pressed("run"):
		character_state = CharacterState.RUN
		is_running = true
	
	if event.is_action_released("run"):
		character_state = CharacterState.WALK
		is_running = false

func set_character_state():
	if is_jumping:
		if is_falling:
			character_state = CharacterState.FALL
		else:
			character_state = CharacterState.JUMP
		
		if is_on_floor():
			is_jumping = false
			is_falling = false
	
	elif is_running:
		character_state = CharacterState.RUN
	
	elif input.is_zero_approx():
		character_state = CharacterState.IDLE
	
	else:
		character_state = CharacterState.WALK

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

func play_animation(anim_name: String) -> void:
	if anim_player.is_playing() and anim_player.current_animation == anim_name:
		return
	
	anim_player.play(anim_name)

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "jump":
		is_falling = true

func _unhandled_input(event):
	if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		if event is InputEventMouseMotion:
			# camera handling on mouse movement
			spring_arm.rotation.x -= event.relative.y * mouse_sensitivity
			spring_arm.rotation_degrees.x = clamp(spring_arm.rotation_degrees.x, -90.0, 30.0)
			spring_arm.rotation.y -= event.relative.x * mouse_sensitivity

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
