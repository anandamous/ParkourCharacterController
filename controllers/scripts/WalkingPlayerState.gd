class_name WalkingPlayerState extends PlayerMovementState

@export var SPEED : float = 4.0
@export var ACCELERATION : float = 0.1
@export var DECELERATION : float = 0.25

#export var TOP_ANIMATION_SPEED : float = 2.2

@onready var CLIMB_SHAPECAST : ShapeCast3D = $"../../ClimbShapecast"
@onready var WALLRUN_RAYCAST_RIGHT : RayCast3D = $"../../WallrunRaycastRight"
@onready var WALLRUN_RAYCAST_LEFT : RayCast3D = $"../../WallrunRaycastLeft"

enum {IDLE, WALK, SPRINT, CROUCH_IDLE, CROUCH_WALK, JUMP, FALL, CLIMB, SLIDE, ROLL}

func enter(previous_state) -> void:
	# OLD ANIMATION CRAP
	#if ANIMATION.is_playing() and ANIMATION.current_animation == "jump_end":
		#await ANIMATION.animation_finished
		#ANIMATION.pause()
	#else:
		#ANIMATION.pause()
		
	# ANIMATION.play("walking",-1.0,1.0)
	PLAYER.current_animation = WALK

func exit() -> void:
	pass
	# ANIMATION.speed_scale = 1.0

func update(delta):
	PLAYER.set_movement_speed(SPEED)
	PLAYER.update_wish_dir()
	PLAYER.update_movement(ACCELERATION, DECELERATION, delta)
	PLAYER.update_velocity()
	
	# set_animation_speed(Global.player.velocity.length())
	
	if Input.is_action_pressed("sprint") and Input.is_action_pressed("move_forward") and Global.player.is_on_floor():
		transition.emit("SprintingPlayerState")
		
	if Input.is_action_just_pressed("crouch") and PLAYER.is_on_floor():
		transition.emit("CrouchingPlayerState")
	
	if Global.player.velocity.length() < 0.05:
		transition.emit("IdlePlayerState")
		
	if PLAYER.is_on_floor() and (Input.is_action_just_pressed("jump") or (Input.is_action_pressed("jump") and PLAYER.auto_jump)):
		PLAYER.velocity.y += 6.0
		transition.emit("JumpingPlayerState")
		
	if not PLAYER.is_on_floor() and Input.is_action_just_pressed("jump"):
		if PLAYER.is_on_wall() and (WALLRUN_RAYCAST_RIGHT.is_colliding() or WALLRUN_RAYCAST_LEFT.is_colliding()):
			transition.emit("WallrunPlayerState")
		elif PLAYER.double_jump > 0:
			PLAYER.update_double_jump(delta)
		
	if PLAYER.velocity.y < -1.0 and !PLAYER.is_on_floor():
		transition.emit("FallingPlayerState")
		
	if Input.is_action_pressed("class_ability") and PLAYER.can_dodge == true:
		transition.emit("DodgePlayerState")
		
#func set_animation_speed(spd):
	#var alpha = remap(spd, 0.0, Global.player.SPEED_DEFAULT, 0.0, 1.0)
	#ANIMATION.speed_scale = lerp(0.0, TOP_ANIMATION_SPEED, alpha)
