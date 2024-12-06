class_name SlidingPlayerState extends PlayerMovementState

@export var SPEED : float = 7.0
@export var ACCELERATION : float = 0.1
@export var DECELERATION : float = 1.0
@export var JUMP_VELOCITY : float = 4.5
@export var ANIMATION_SPEED : float = 4.0
#@export_range(1, 6, 0.1) var SLIDE_SPEED : float = 1.0

# To detect if colliding with object above
@onready var CROUCH_SHAPECAST : ShapeCast3D = $"../../CrouchShapecast"
@onready var SLIDE_SHAPECAST_BACK : ShapeCast3D = $"../../SlideCheckBack"
@onready var SLIDE_SHAPECAST_FRONT : ShapeCast3D = $"../../SlideCheckFront"

enum {IDLE, WALK, SPRINT, CROUCH_IDLE, CROUCH_WALK, JUMP, FALL, CLIMB, SLIDE, ROLL}

func enter(previous_state) -> void:
	if ANIMATION.is_playing() and ANIMATION.current_animation == "crouch":
		await ANIMATION.animation_finished
		ANIMATION.pause()
	else:
		ANIMATION.pause()
		
	ANIMATION.play("crouch", -1.0, ANIMATION_SPEED)
	
	PLAYER.slide_speed = 0.0
	
	PLAYER.current_animation = SLIDE

func update(delta):
	PLAYER.update_slide(delta)
	PLAYER.update_velocity()
	
	if Input.is_action_just_pressed("crouch"):
		unslide()
		
	if Input.is_action_just_pressed("sprint"):
		unslide()
		transition.emit("SprintingPlayerState")
		
	if PLAYER.is_on_floor() and (Input.is_action_just_pressed("jump") or (Input.is_action_pressed("jump") and PLAYER.auto_jump)):
		unslide()
		PLAYER.velocity.y += 6.0
		transition.emit("JumpingPlayerState")
		
	if Input.is_action_just_released("jump"):
		if PLAYER.velocity.y > 0:
			PLAYER.velocity.y = PLAYER.velocity.y / 2.0
			
	if PLAYER.velocity.length() < 2.0:
		unslide()
		transition.emit("CrouchingPlayerState")
	
func finish():
	unslide()
	
func unslide():
	if CROUCH_SHAPECAST.is_colliding() == false:
		ANIMATION.play("crouch", -1.0, -ANIMATION_SPEED * 1.5, true)
		await ANIMATION.animation_finished
		if PLAYER.velocity.length() == 0:
			transition.emit("IdlePlayerState")
		else:
			transition.emit("SprintingPlayerState")
		PLAYER.sliding = false
	elif CROUCH_SHAPECAST.is_colliding() == true:
		await get_tree().create_timer(0.1).timeout
		unslide()
	
	
