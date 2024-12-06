class_name Player

extends CharacterBody3D

@export var MOUSE_SENSITIVITY : float = 0.5
@export var TILT_LOWER_LIMIT := deg_to_rad(-80.0)
@export var TILT_UPPER_LIMIT := deg_to_rad(70.0)
@export var CAMERA_CONTROLLER : Camera3D
@export var ANIMATIONPLAYER : AnimationPlayer
@export var CROUCH_SHAPECAST : Node3D
@export var SLIDE_SHAPECAST_BACK : ShapeCast3D
@export var SLIDE_SHAPECAST_FRONT : ShapeCast3D
@export var HEALTH_BAR : TextureProgressBar
@export var SPEED_BAR : TextureProgressBar
@export var SPRING_ARM : SpringArm3D
@export var DODGE_ABILITY : TextureProgressBar
@export var DIVE_ABILITY : TextureProgressBar
@export var SHOCKWAVE_SCREEN_EFFECT : ColorRect
@export var SPEED_LINES_SCREEN_EFFECT : ColorRect
@export var ANIM_TREE : AnimationTree
@export var CAMERA_ROOT : Node3D
@export var ANIMATIONMODELPLAYER : AnimationPlayer

# Camera variables
const TILT_AMOUNT = 0.05  # Adjust this value to control the tilt intensity
const TILT_SPEED = 2.0   # Adjust this value to control the speed of tilt interpolation
var tiltx : float = 0.0
var tiltz : float = 0.0
const BASE_FOV = 70.0
const FOV_CHANGE = 2.5

var _mouse_input : bool = false
var _rotation_input : float
var _tilt_input : float
var _mouse_rotation : Vector3
var _player_rotation : Vector3
var _camera_rotation : Vector3

var _current_rotation : float

# Player variables
var can_climb : bool = true
var double_jump : int = 2.0
var max_double_jumps : int = 2.0
var double_jump_velocity : float = 7.0

# Movement Variables
var gravity = 9.8

var input_dir := Vector3.ZERO
var wish_dir := Vector3.ZERO
var slide_wish_dir := Vector3.ZERO

@export var auto_jump := true

var _speed : float

var air_time : float
var wallrun_side : String 
var wallrun_tilt : float = 0.0
var wall_jump_dir_x
var wall_jump_dir_z

# Sliding
var fall_distance = 0
var slide_speed = 0
var sliding = false
var falling = false

# Third and first person cameras
var first_person_position : Vector3 = Vector3(0, 0, 0)
var third_person_position : Vector3 = Vector3(0.5, 0, 0)
var third_person_mode : bool = false

# Abilities
var can_dodge := false
var dodge_cooldown_progress := 0.0
@export var dodge_cooldown := 2.0
var can_bullet_time := true
var bullet_time_cooldown_progress : float = 0.0
@export var bullet_time_cooldown : float = 12.0
var can_dive := false
var dive_cooldown_progress := 2.0
@export var dive_cooldown := 2.0

# Effects
var ripple_effect_radius := 0.0

# Animations
enum {IDLE, WALK, SPRINT, CROUCH_IDLE, CROUCH_WALK, JUMP, FALL, CLIMB, SLIDE, ROLL}
var current_animation = IDLE
var idle_val = 0.0
var walk_val = 0.0
var sprint_val = 0.0
var crouch_idle_val = 0.0
var crouch_walk_val = 0.0
var jump_val = 0.0
var fall_val = 0.0
var climb_val = 0.0
var slide_val = 0.0
var roll_val = 0.0
@export var anim_blend_speed = 10.0

func _unhandled_input(event: InputEvent) -> void:
	_mouse_input = event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED
	if _mouse_input:
		_rotation_input = -event.relative.x * MOUSE_SENSITIVITY
		_tilt_input = -event.relative.y * MOUSE_SENSITIVITY

func _input(event):
	if event.is_action_pressed("exit"):
		get_tree().quit()

func update_camera(delta) -> void:
	
	_current_rotation = _rotation_input
	_mouse_rotation.x += _tilt_input * delta
	_mouse_rotation.x = clamp(_mouse_rotation.x, TILT_LOWER_LIMIT, TILT_UPPER_LIMIT)
	_mouse_rotation.y += _rotation_input * delta

	_player_rotation = Vector3(0.0, _mouse_rotation.y, 0.0)
	_camera_rotation = Vector3(_mouse_rotation.x, 0.0, 0.0)

	if third_person_mode == false:
		CAMERA_CONTROLLER.transform.basis = Basis.from_euler(_camera_rotation)
	else: 
		SPRING_ARM.transform.basis = Basis.from_euler(_camera_rotation)
	global_transform.basis = Basis.from_euler(_player_rotation)
	
	var velocity_clamped = clamp(velocity.length(), 0.5, 20.0)
	var target_fov = BASE_FOV + FOV_CHANGE * velocity_clamped
	CAMERA_CONTROLLER.fov = lerp(CAMERA_CONTROLLER.fov, target_fov, delta * 2.0)

	CAMERA_CONTROLLER.rotation.z = 0

	_rotation_input = 0.0
	_tilt_input = 0.0

	if third_person_mode == false:
		SPRING_ARM.spring_length = lerp(SPRING_ARM.spring_length, 0.0, 10.0 * delta)
		SPRING_ARM.position = lerp(SPRING_ARM.position, first_person_position, 10.0 * delta)
	else:
		SPRING_ARM.spring_length = lerp(SPRING_ARM.spring_length, 2.0, 10.0 * delta)
		SPRING_ARM.position = lerp(SPRING_ARM.position, third_person_position, 10.0 * delta)

func _ready():
	Global.player = self
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	CROUCH_SHAPECAST.add_exception($".")
	
	SPRING_ARM.add_excluded_object($".")
	SPRING_ARM.add_excluded_object($CollisionShape3D)
	
	HEALTH_BAR.max_value = bullet_time_cooldown
	DODGE_ABILITY.max_value = dodge_cooldown
	DIVE_ABILITY.max_value = dive_cooldown
	
	update_animation_tree()
	
func _physics_process(delta):
	Global.debug.add_property("Velocity", "%.2f" % velocity.length(), 2)
	Global.debug.add_property("Slide Speed", "%.2f" % slide_speed, 3)
	Global.debug.add_property("Fall Distance", "%.2f" % fall_distance, 4)
	Global.debug.add_property("Air Time", "%.2f" % air_time, 5)
	Global.debug.add_property("Facing Direction", -transform.basis.z.normalized(), 6)
	Global.debug.add_property("Wish Direction", wish_dir, 7)
	
	SPEED_BAR.value = velocity.length()
	
	get_air_time(delta)
	update_camera(delta)
	update_abilities(delta)
	
	if Input.is_action_pressed("bullet_time") and (bullet_time_cooldown_progress <= bullet_time_cooldown):
		Engine.time_scale = lerp(Engine.time_scale, 0.25, 0.5)
		bullet_time_cooldown_progress += delta * 4.0
		
		SHOCKWAVE_SCREEN_EFFECT.visible = true
		ripple_effect_radius = lerp(ripple_effect_radius, 0.75, 10.0 * delta)
		SHOCKWAVE_SCREEN_EFFECT.material.set_shader_parameter("radius", ripple_effect_radius)
	else:
		Engine.time_scale = lerp(Engine.time_scale, 1.0, 10.0 * delta)
		
		ripple_effect_radius = lerp(ripple_effect_radius, 0.0, 10.0 * delta)
		SHOCKWAVE_SCREEN_EFFECT.material.set_shader_parameter("radius", ripple_effect_radius)
		if ripple_effect_radius == 0.0:
			SHOCKWAVE_SCREEN_EFFECT.visible = false
		
	if Input.is_action_just_pressed("switch_camera_mode"):
		update_camera_mode()
		
	if velocity.length() >= 10.0:
		SPEED_LINES_SCREEN_EFFECT.visible = true
	else:
		SPEED_LINES_SCREEN_EFFECT.visible = false
		
	handle_animations(delta)
	
	if Input.is_action_just_pressed("reset"):
		position = Vector3(0.0,10.0,0.0)
		
func update_gravity(multiplier: float, delta: float) -> void:
	velocity.y -= gravity * multiplier * delta
	
func update_wish_dir() -> void:
	var input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	wish_dir = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	#tiltz = lerp(tiltz, -input_dir.x * TILT_AMOUNT, 0.007 * TILT_SPEED)
	#CAMERA_CONTROLLER.rotation.z = tiltz

func update_movement(acceleration: float, deceleration: float, delta: float) -> void:
	# HANDLE GROUND PHYSICS
	if is_on_floor():
		double_jump = max_double_jumps
		if wish_dir:
			velocity.x = lerp(velocity.x, wish_dir.x * _speed, acceleration)
			velocity.z = lerp(velocity.z, wish_dir.z * _speed, acceleration)
		else:
			velocity.x = lerp(velocity.x, 0.0, deceleration)
			velocity.z = lerp(velocity.z, 0.0, deceleration)
	# HANDLE AIR PHYSICS
	else:
		velocity.y -= gravity * delta
		velocity.x = lerp(velocity.x, wish_dir.x * _speed, (acceleration * 0.1)/velocity.length())
		velocity.z = lerp(velocity.z, wish_dir.z * _speed, (acceleration * 0.1)/velocity.length())
	
func update_double_jump(delta) -> void:
	velocity.y = double_jump_velocity
	velocity.x += wish_dir.x * 1.0
	velocity.z += wish_dir.z * 1.0
	double_jump -= 1
	
func update_slide(delta: float) -> void:
	
	var slide_dot = wish_dir.dot(-transform.basis.z.normalized())
	
	# wish_dir = lerp(wish_dir, -transform.basis.z.normalized(), 0.002)
	
	velocity.y -= gravity * delta
	if not sliding:
		if SLIDE_SHAPECAST_BACK.is_colliding() or get_floor_angle() > 0.01:
			slide_speed = velocity.length()
			slide_speed += abs(fall_distance / 10)
		else:
			slide_speed = velocity.length()
	sliding = true
	
	if slide_dot < 0:
		if SLIDE_SHAPECAST_FRONT.is_colliding():
			slide_speed -= get_floor_angle() / 15
		elif is_on_floor():
			slide_speed -= (get_floor_angle() / 5) + 0.00875
		else:
			slide_speed -= 0.001
	else:
		if SLIDE_SHAPECAST_BACK.is_colliding():
			slide_speed += get_floor_angle() / 15
		elif is_on_floor():
			slide_speed -= (get_floor_angle() / 5) + 0.00875
		else:
			slide_speed -= 0.001
			
	if slide_speed < 0:
		sliding = false
		slide_speed = 0
	
	velocity.x = lerp(velocity.x, wish_dir.x * slide_speed, 0.1)
	velocity.z = lerp(velocity.z, wish_dir.z * slide_speed, 0.1)
	
func update_wallrun(acceleration: float, deceleration: float, delta: float) -> void:
	# Get collision data of the wall, and it's normal
	var collision = get_slide_collision(0)
	var normal = collision.get_normal()

	# Calculate the direction which we have to move
	var wallrun_dir = Vector3.UP.cross(normal)

	# Change running direction depending on view direction
	var player_view_dir = -CAMERA_CONTROLLER.global_transform.basis.z
	var dot = wallrun_dir.dot(player_view_dir)
	if dot < 0:
		wallrun_dir = -wallrun_dir
			
	# Adding a little bit of push towards the wall 
	wallrun_dir += -normal * 10.0
	
	# Sets side to a string, that tells where the wall is with respect to the player
	wallrun_side = wallrun_get_side(collision.get_position())
		
	velocity.y -= gravity * 0.1 * delta
	wish_dir = wallrun_dir
	
	var wallrun_speed = 0.0
	if Input.is_action_pressed("move_forward"):
		velocity.x = lerp(velocity.x, wish_dir.x * _speed, acceleration)
		velocity.z = lerp(velocity.z, wish_dir.z * _speed, acceleration)
	else:
		velocity.x = lerp(velocity.x, 0.0, deceleration)
		velocity.z = lerp(velocity.z, 0.0, deceleration)
	
func wallrun_jump():
	velocity.y = 4.0

	# Determine the wall jump direction based on which side the wall is on
	if wallrun_side == "LEFT":
		wall_jump_dir_x = global_transform.basis.x
	elif wallrun_side == "RIGHT":
		wall_jump_dir_x = -global_transform.basis.x
	
	# Factor in the player's input direction to combine with the wall jump direction
	wall_jump_dir_x *= 5.0
	wish_dir = wall_jump_dir_x
	velocity += wall_jump_dir_x
	
func wallrun_get_side(point):
	point = to_local(point)
	
	if point.x > 0:
		return "RIGHT"
	elif point.x < 0:
		return "LEFT"
	else:
		return "CENTER"
	
func update_climb(speed: float, acceleration: float, deceleration: float, delta: float) -> void:
	if wish_dir:
		velocity.x = lerp(velocity.x, wish_dir.x * speed, acceleration)
		velocity.z = lerp(velocity.z, wish_dir.z * speed, acceleration)
	else:
		velocity.x = lerp(velocity.x, 0.0, deceleration)
		velocity.z = lerp(velocity.z, 0.0, deceleration)
		
func update_dodge() -> void:
	velocity.x += wish_dir.x * _speed
	velocity.z += wish_dir.z * _speed
	
func get_air_time(delta):
	if !is_on_floor():
		air_time += delta
	else:
		air_time = 0

func set_movement_speed(set_speed: float):
	_speed = set_speed
	
func update_velocity() -> void:
	move_and_slide()
	
func update_camera_mode() -> void:
	if third_person_mode == false:
		switch_to_third_person()
	else:
		switch_to_first_person()
		
func switch_to_third_person() -> void:
	third_person_mode = true
	CAMERA_CONTROLLER.transform.basis = SPRING_ARM.transform.basis
	SPRING_ARM.transform.basis = Basis.from_euler(Vector3(0.0, 0.0, 0.0))
	
func switch_to_first_person() -> void:
	third_person_mode = false
	SPRING_ARM.transform.basis = CAMERA_CONTROLLER.transform.basis
	CAMERA_CONTROLLER.transform.basis = Basis.from_euler(Vector3(0.0, 0.0, 0.0))

func update_abilities(delta) -> void:
	# Dodge
	if can_dodge == false:
		dodge_cooldown_progress -= delta
		DODGE_ABILITY.value = dodge_cooldown - dodge_cooldown_progress
		if dodge_cooldown_progress <= 0.0:
			can_dodge = true
			
	# Bullet Time
	if (bullet_time_cooldown_progress >= 0.0 and !Input.is_action_pressed("bullet_time")) or can_bullet_time == false:
		bullet_time_cooldown_progress -= delta
	HEALTH_BAR.value = bullet_time_cooldown - bullet_time_cooldown_progress
	
	# Dive
	if can_dive == false:
		dive_cooldown_progress -= delta
		if dive_cooldown_progress <= 0.0:
			can_dive = true
	DIVE_ABILITY.value = dive_cooldown - dive_cooldown_progress
	
func handle_animations(delta):
	match current_animation:
		IDLE:
			walk_val = lerp(walk_val, 0.0, anim_blend_speed * delta)
			sprint_val = lerp(sprint_val, 0.0, anim_blend_speed * delta)
			crouch_idle_val = lerp(crouch_idle_val, 0.0, anim_blend_speed * delta)
			crouch_walk_val = lerp(crouch_walk_val, 0.0, anim_blend_speed * delta)
			jump_val = lerp(jump_val, 0.0, anim_blend_speed * delta)
			fall_val = lerp(fall_val, 0.0, anim_blend_speed * delta)
			climb_val = lerp(climb_val, 0.0, anim_blend_speed * delta)
			slide_val = lerp(slide_val, 0.0, anim_blend_speed * delta)
			roll_val = lerp(roll_val, 0.0, anim_blend_speed * delta)
			if third_person_mode == false:
				CAMERA_ROOT.position = lerp(CAMERA_ROOT.position, Vector3(0,0.645,-0.215), anim_blend_speed * delta)
			else:
				CAMERA_ROOT.position = lerp(CAMERA_ROOT.position, Vector3(0.0,0.7,0.0), anim_blend_speed * delta)
		WALK:
			walk_val = lerp(walk_val, 1.0, anim_blend_speed * delta)
			sprint_val = lerp(sprint_val, 0.0, anim_blend_speed * delta)
			crouch_idle_val = lerp(crouch_idle_val, 0.0, anim_blend_speed * delta)
			crouch_walk_val = lerp(crouch_walk_val, 0.0, anim_blend_speed * delta)
			jump_val = lerp(jump_val, 0.0, anim_blend_speed * delta)
			fall_val = lerp(fall_val, 0.0, anim_blend_speed * delta)
			climb_val = lerp(climb_val, 0.0, anim_blend_speed * delta)
			slide_val = lerp(slide_val, 0.0, anim_blend_speed * delta)
			roll_val = lerp(roll_val, 0.0, anim_blend_speed * delta)
			if third_person_mode == false:
				CAMERA_ROOT.position = lerp(CAMERA_ROOT.position, Vector3(0,0.745,-0.14), anim_blend_speed * delta)
			else:
				CAMERA_ROOT.position = lerp(CAMERA_ROOT.position, Vector3(0.0,0.7,0.0), anim_blend_speed * delta)
		SPRINT:
			walk_val = lerp(walk_val, 0.0, anim_blend_speed * delta)
			sprint_val = lerp(sprint_val, 1.0, anim_blend_speed * delta)
			crouch_idle_val = lerp(crouch_idle_val, 0.0, anim_blend_speed * delta)
			crouch_walk_val = lerp(crouch_walk_val, 0.0, anim_blend_speed * delta)
			jump_val = lerp(jump_val, 0.0, anim_blend_speed * delta)
			fall_val = lerp(fall_val, 0.0, anim_blend_speed * delta)
			climb_val = lerp(climb_val, 0.0, anim_blend_speed * delta)
			slide_val = lerp(slide_val, 0.0, anim_blend_speed * delta)
			roll_val = lerp(roll_val, 0.0, anim_blend_speed * delta)
			if third_person_mode == false:
				CAMERA_ROOT.position = lerp(CAMERA_ROOT.position, Vector3(0,0.45,-0.525), anim_blend_speed * delta)
			else:
				CAMERA_ROOT.position = lerp(CAMERA_ROOT.position, Vector3(0.0,0.7,0.0), anim_blend_speed * delta)
		CROUCH_IDLE:
			walk_val = lerp(walk_val, 0.0, anim_blend_speed * delta)
			sprint_val = lerp(sprint_val, 0.0, anim_blend_speed * delta)
			crouch_idle_val = lerp(crouch_idle_val, 1.0, anim_blend_speed * delta)
			crouch_walk_val = lerp(crouch_walk_val, 0.0, anim_blend_speed * delta)
			jump_val = lerp(jump_val, 0.0, anim_blend_speed * delta)
			fall_val = lerp(fall_val, 0.0, anim_blend_speed * delta)
			climb_val = lerp(climb_val, 0.0, anim_blend_speed * delta)
			slide_val = lerp(slide_val, 0.0, anim_blend_speed * delta)
			roll_val = lerp(roll_val, 0.0, anim_blend_speed * delta)
			if third_person_mode == false:
				CAMERA_ROOT.position = lerp(CAMERA_ROOT.position, Vector3(0.1,0.3,-0.375), anim_blend_speed * delta)
			else:
				CAMERA_ROOT.position = lerp(CAMERA_ROOT.position, Vector3(0.0,0.7,0.0), anim_blend_speed * delta)
		CROUCH_WALK:
			walk_val = lerp(walk_val, 0.0, anim_blend_speed * delta)
			sprint_val = lerp(sprint_val, 0.0, anim_blend_speed * delta)
			crouch_idle_val = lerp(crouch_idle_val, 0.0, anim_blend_speed * delta)
			crouch_walk_val = lerp(crouch_walk_val, 1.0, anim_blend_speed * delta)
			jump_val = lerp(jump_val, 0.0, anim_blend_speed * delta)
			fall_val = lerp(fall_val, 0.0, anim_blend_speed * delta)
			climb_val = lerp(climb_val, 0.0, anim_blend_speed * delta)
			slide_val = lerp(slide_val, 0.0, anim_blend_speed * delta)
			roll_val = lerp(roll_val, 0.0, anim_blend_speed * delta)
			if third_person_mode == false:
				CAMERA_ROOT.position = lerp(CAMERA_ROOT.position, Vector3(0.3,0.2,-0.625), anim_blend_speed * delta)
			else:
				CAMERA_ROOT.position = lerp(CAMERA_ROOT.position, Vector3(0.0,0.7,0.0), anim_blend_speed * delta)
		JUMP:
			walk_val = lerp(walk_val, 0.0, anim_blend_speed * delta)
			sprint_val = lerp(sprint_val, 0.0, anim_blend_speed * delta)
			crouch_idle_val = lerp(crouch_idle_val, 0.0, anim_blend_speed * delta)
			crouch_walk_val = lerp(crouch_walk_val, 0.0, anim_blend_speed * delta)
			jump_val = lerp(jump_val, 1.0, anim_blend_speed * delta)
			fall_val = lerp(fall_val, 0.0, anim_blend_speed * delta)
			climb_val = lerp(climb_val, 0.0, anim_blend_speed * delta)
			slide_val = lerp(slide_val, 0.0, anim_blend_speed * delta)
			roll_val = lerp(roll_val, 0.0, anim_blend_speed * delta)
			if third_person_mode == false:
				CAMERA_ROOT.position = lerp(CAMERA_ROOT.position, Vector3(0.0,0.45,-0.3), anim_blend_speed * delta)
			else:
				CAMERA_ROOT.position = lerp(CAMERA_ROOT.position, Vector3(0.0,0.7,0.0), anim_blend_speed * delta)
		FALL:
			walk_val = lerp(walk_val, 0.0, anim_blend_speed * delta)
			sprint_val = lerp(sprint_val, 0.0, anim_blend_speed * delta)
			crouch_idle_val = lerp(crouch_idle_val, 0.0, anim_blend_speed * delta)
			crouch_walk_val = lerp(crouch_walk_val, 0.0, anim_blend_speed * delta)
			jump_val = lerp(jump_val, 0.0, anim_blend_speed * delta)
			fall_val = lerp(fall_val, 1.0, anim_blend_speed * delta)
			climb_val = lerp(climb_val, 0.0, anim_blend_speed * delta)
			slide_val = lerp(slide_val, 0.0, anim_blend_speed * delta)
			roll_val = lerp(roll_val, 0.0, anim_blend_speed * delta)
			if third_person_mode == false:
				CAMERA_ROOT.position = lerp(CAMERA_ROOT.position, Vector3(0.0,0.45,-0.5), anim_blend_speed * delta)
			else:
				CAMERA_ROOT.position = lerp(CAMERA_ROOT.position, Vector3(0.0,0.7,0.0), anim_blend_speed * delta)
		CLIMB:
			walk_val = lerp(walk_val, 0.0, anim_blend_speed * delta)
			sprint_val = lerp(sprint_val, 0.0, anim_blend_speed * delta)
			crouch_idle_val = lerp(crouch_idle_val, 0.0, anim_blend_speed * delta)
			crouch_walk_val = lerp(crouch_walk_val, 0.0, anim_blend_speed * delta)
			jump_val = lerp(jump_val, 0.0, anim_blend_speed * delta)
			fall_val = lerp(fall_val, 0.0, anim_blend_speed * delta)
			climb_val = lerp(climb_val, 1.0, anim_blend_speed * delta)
			slide_val = lerp(slide_val, 0.0, anim_blend_speed * delta)
			roll_val = lerp(roll_val, 0.0, anim_blend_speed * delta)
			if third_person_mode == false:
				CAMERA_ROOT.position = lerp(CAMERA_ROOT.position, Vector3(-0.125,0.9,0.05), anim_blend_speed * delta)
			else:
				CAMERA_ROOT.position = lerp(CAMERA_ROOT.position, Vector3(0.0,0.7,0.0), anim_blend_speed * delta)
		SLIDE:
			walk_val = lerp(walk_val, 0.0, anim_blend_speed * delta)
			sprint_val = lerp(sprint_val, 0.0, anim_blend_speed * delta)
			crouch_idle_val = lerp(crouch_idle_val, 0.0, anim_blend_speed * delta)
			crouch_walk_val = lerp(crouch_walk_val, 0.0, anim_blend_speed * delta)
			jump_val = lerp(jump_val, 0.0, anim_blend_speed * delta)
			fall_val = lerp(fall_val, 0.0, anim_blend_speed * delta)
			climb_val = lerp(climb_val, 0.0, anim_blend_speed * delta)
			slide_val = lerp(slide_val, 1.0, anim_blend_speed * delta)
			roll_val = lerp(roll_val, 0.0, anim_blend_speed * delta)
			if third_person_mode == false:
				CAMERA_ROOT.position = lerp(CAMERA_ROOT.position, Vector3(0.1,0.3,-0.375), anim_blend_speed * delta)
			else:
				CAMERA_ROOT.position = lerp(CAMERA_ROOT.position, Vector3(0.0,0.7,0.0), anim_blend_speed * delta)
			
	ANIM_TREE["parameters/Walk/blend_amount"] = walk_val
	ANIM_TREE["parameters/Sprint/blend_amount"] = sprint_val
	ANIM_TREE["parameters/CrouchIdle/blend_amount"] = crouch_idle_val
	ANIM_TREE["parameters/CrouchWalk/blend_amount"] = crouch_walk_val
	ANIM_TREE["parameters/Jump/blend_amount"] = jump_val
	ANIM_TREE["parameters/Fall/blend_amount"] = fall_val
	ANIM_TREE["parameters/Climb/blend_amount"] = climb_val
	ANIM_TREE["parameters/Slide/blend_amount"] = slide_val
			
func update_animation_tree():
	pass
	
