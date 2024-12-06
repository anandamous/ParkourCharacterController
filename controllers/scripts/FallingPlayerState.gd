class_name FallingPlayerState extends PlayerMovementState

@export var SPEED : float = 5.0
@export var ACCELERATION : float = 0.1
@export var DECELERATION : float = 0.25
@export var DOUBLE_JUMP_VELOCITY : float = 6.0
@export var TRIPLE_JUMP_VELOCITY : float = 7.0

@onready var CLIMB_SHAPECAST : ShapeCast3D = $"../../ClimbShapecast"
@onready var WALLRUN_RAYCAST_RIGHT : RayCast3D = $"../../WallrunRaycastRight"
@onready var WALLRUN_RAYCAST_LEFT : RayCast3D = $"../../WallrunRaycastLeft"

enum {IDLE, WALK, SPRINT, CROUCH_IDLE, CROUCH_WALK, JUMP, FALL, CLIMB, SLIDE, ROLL}

func enter(previous_state) -> void:
	ANIMATION.pause()
	
	PLAYER.current_animation = FALL

func update(delta):
	PLAYER.set_movement_speed(SPEED)
	PLAYER.update_wish_dir()
	PLAYER.update_movement(ACCELERATION, DECELERATION, delta)
	PLAYER.update_velocity()
			
	if PLAYER.is_on_floor():
		if Input.is_action_pressed("crouch") and Input.is_action_pressed("sprint") and PLAYER.velocity.length() > 1:
			ANIMATION.play("jump_end")
			transition.emit("SlidingPlayerState")
		else:
			ANIMATION.play("jump_end")
			transition.emit("IdlePlayerState")
		
	if Input.is_action_just_pressed("jump") and PLAYER.double_jump > 0:
		PLAYER.update_double_jump(delta)
			
	if Input.is_action_pressed("jump"):
		if PLAYER.is_on_wall() and (WALLRUN_RAYCAST_RIGHT.is_colliding() or WALLRUN_RAYCAST_LEFT.is_colliding()):
			transition.emit("WallrunPlayerState")
		
	if Input.is_action_pressed("move_forward") and Input.is_action_pressed("jump") and CLIMB_SHAPECAST.is_colliding():
		transition.emit("ClimbingPlayerState")
		
	if Input.is_action_pressed("air_ability") and PLAYER.can_dive == true:
		transition.emit("DivePlayerState")
