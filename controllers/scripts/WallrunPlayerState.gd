class_name WallrunPlayerState extends PlayerMovementState

@export var SPEED : float = 7.0
@export var ACCELERATION : float = 0.1
@export var DECELERATION : float = 0.01

@onready var WALLRUN_RAYCAST_RIGHT : RayCast3D = $"../../WallrunRaycastRight"
@onready var WALLRUN_RAYCAST_LEFT : RayCast3D = $"../../WallrunRaycastLeft"

enum {IDLE, WALK, SPRINT, CROUCH_IDLE, CROUCH_WALK, JUMP, FALL, CLIMB, SLIDE, ROLL}

func enter(previous_state) -> void:
	ANIMATION.pause()
	PLAYER.double_jump = PLAYER.max_double_jumps
	PLAYER.velocity.y = 0.0
	#if PLAYER.third_person_mode == true:
	#	PLAYER.switch_to_first_person()
	
	PLAYER.current_animation = SPRINT

func update(delta):
	PLAYER.set_movement_speed(SPEED)
	PLAYER.update_wish_dir()
	PLAYER.update_wallrun(ACCELERATION, DECELERATION, delta)
	PLAYER.update_velocity()
	
	if Input.is_action_just_pressed("jump"):
		PLAYER.wallrun_jump()
		transition.emit("JumpingPlayerState")
		
	if !PLAYER.is_on_wall():
		transition.emit("FallingPlayerState")
		
	if PLAYER.is_on_floor():
		transition.emit("IdlePlayerState")
		
	# if PLAYER.velocity.length() < 0.1:
		# transition.emit("FallingPlayerState")
