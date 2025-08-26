extends CharacterBody3D

# references
@onready var spring_arm = $SpringArm3D # camera arm
@onready var anim_player = $CharacterModel/AnimationPlayer
@onready var model = $CharacterModel

# editor exported state
@export var speed = 10.0
@export var acceleration = 5.0
@export var jump_speed = 8.0

@export var mouse_sensitivity = 0.0015
@export var rotation_speed = 12.0

# state
var input = Vector2.ZERO
var is_jumping = false
var is_running = false

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready() -> void:
	#GlobalState.initialize_level()
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	
	if event.is_action_pressed("click"):
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
	if event.is_action_pressed("run"):
		is_running = true
	
	if event.is_action_released("run"):
		is_running = false

func _physics_process(delta):
	#if GlobalState.game_over:
		#Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		#game_over()
	velocity.y += -gravity * delta
	get_move_input(delta)
	move_and_slide()
	
	handle_animation()
	
	if velocity.length() > 1.0:
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
	if input.is_zero_approx():
		anim_player.play("idle")
	elif is_running:
		anim_player.play("sprint")
	else:
		anim_player.play("walk")

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
	set_physics_process(false)
	await get_tree().create_timer(1).timeout
	#get_tree().change_scene_to_file("res://Scenes/end_screen.tscn")
