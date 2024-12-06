class_name IdlePlayerState extends PlayerMovementState

@export var SPEED : float = 4.0
@export var ACCELERATION : float = 0.1
@export var DECELERATION : float = 0.25

@onready var CLIMB_SHAPECAST : ShapeCast3D = $"../../ClimbShapecast"

enum {IDLE, WALK, SPRINT, CROUCH_IDLE, CROUCH_WALK, JUMP, FALL, CLIMB, SLIDE, ROLL}

func enter(previous_state) -> void:
	# OLD JUMP END ANIMATION CRAP
	#if ANIMATION.is_playing() and ANIMATION.current_animation == "jump_end":
		#await ANIMATION.animation_finished
		#ANIMATION.pause()
	#else:
		#ANIMATION.pause()
	PLAYER.current_animation = IDLE

func update(delta):
	PLAYER.update_wish_dir()
	PLAYER.update_movement(ACCELERATION, DECELERATION, delta)
	PLAYER.update_velocity()
	
	if Input.is_action_just_pressed("crouch") and PLAYER.is_on_floor():
		transition.emit("CrouchingPlayerState")
	
	if PLAYER.velocity.length() > 0.05 and PLAYER.is_on_floor():
		transition.emit("WalkingPlayerState")

	if PLAYER.is_on_floor() and (Input.is_action_just_pressed("jump") or (Input.is_action_pressed("jump") and PLAYER.auto_jump)):
		PLAYER.velocity.y += 6.0
		transition.emit("JumpingPlayerState")
		
	if PLAYER.velocity.y < -3.0 and !PLAYER.is_on_floor():
		transition.emit("FallingPlayerState")
		
	if Input.is_action_pressed("move_forward") and Input.is_action_pressed("jump") and CLIMB_SHAPECAST.is_colliding():
		transition.emit("ClimbingPlayerState")
