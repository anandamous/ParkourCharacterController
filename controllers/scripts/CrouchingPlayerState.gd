class_name CrouchingPlayerState extends PlayerMovementState

@export var SPEED : float = 3.0
@export var ACCELERATION : float = 0.1
@export var DECELERATION : float = 0.25
@export_range(1, 6, 0.1) var CROUCH_SPEED : float = 6.0

@onready var CROUCH_SHAPECAST : ShapeCast3D = $"../../CrouchShapecast"

enum {IDLE, WALK, SPRINT, CROUCH_IDLE, CROUCH_WALK, JUMP, FALL, CLIMB, SLIDE, ROLL}

var RELEASED : bool = false

func enter(previous_state) -> void:
	ANIMATION.speed_scale = 1.0
	if previous_state.name != "SlidingPlayerState":
		ANIMATION.play("crouch", -1.0, CROUCH_SPEED)
	elif previous_state.name == "SlidingPlayerState":
		ANIMATION.current_animation = "crouch"
		ANIMATION.seek(1.0, true)
		
	PLAYER.current_animation = CROUCH_IDLE
	
func exit():
	RELEASED = false

func update(delta):
	PLAYER.set_movement_speed(SPEED)
	PLAYER.update_wish_dir()
	PLAYER.update_movement(ACCELERATION, DECELERATION, delta)
	PLAYER.update_velocity()
	
	if PLAYER.velocity.length() < 0.01:
		PLAYER.current_animation = CROUCH_IDLE
	else:
		PLAYER.current_animation = CROUCH_WALK
	
	if Input.is_action_just_released("crouch"):
		uncrouch()
	if Input.is_action_pressed("crouch") == false and RELEASED == false:
		RELEASED = true
		uncrouch()
		
	if PLAYER.velocity.y < -3.0 and !PLAYER.is_on_floor():
		transition.emit("FallingPlayerState")
		
func uncrouch():
	if CROUCH_SHAPECAST.is_colliding() == false:
		ANIMATION.play("crouch", -1.0, -CROUCH_SPEED * 1.5, true)
		await ANIMATION.animation_finished
		if PLAYER.velocity.length() == 0:
			transition.emit("IdlePlayerState")
		else:
			transition.emit("WalkingPlayerState")
	elif CROUCH_SHAPECAST.is_colliding() == true:
		await get_tree().create_timer(0.1).timeout
		uncrouch()
