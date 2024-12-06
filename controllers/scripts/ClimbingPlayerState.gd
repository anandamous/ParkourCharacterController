class_name ClimbingPlayerState extends PlayerMovementState

@export var SPEED : float = 5.0
@export var ACCELERATION : float = 0.1
@export var DECELERATION : float = 0.25

#export var TOP_ANIMATION_SPEED : float = 2.2

@onready var CLIMB_SHAPECAST : ShapeCast3D = $"../../ClimbShapecast"

enum {IDLE, WALK, SPRINT, CROUCH_IDLE, CROUCH_WALK, JUMP, FALL, CLIMB, SLIDE, ROLL}

func enter(previous_state) -> void:
	#if ANIMATION.is_playing() and ANIMATION.current_animation == "jump_end":
		#await ANIMATION.animation_finished
		#ANIMATION.pause()
	#else:
		#ANIMATION.pause()
		
	pass
	
	PLAYER.current_animation = CLIMB

func exit() -> void:
	pass
	# ANIMATION.speed_scale = 1.0

func update(delta):
	PLAYER.velocity.y = 5.0
	PLAYER.update_wish_dir()
	PLAYER.update_climb(SPEED, ACCELERATION, DECELERATION, delta)
	PLAYER.update_velocity()
	
	if Input.is_action_just_released("jump"):
		transition.emit("FallingPlayerState")
	
	if !CLIMB_SHAPECAST.is_colliding():
		transition.emit("FallingPlayerState")
		
	if PLAYER.velocity.y < -1.0:
		transition.emit("FallingPlayerState")
		
#func set_animation_speed(spd):
	#var alpha = remap(spd, 0.0, Global.player.SPEED_DEFAULT, 0.0, 1.0)
	#ANIMATION.speed_scale = lerp(0.0, TOP_ANIMATION_SPEED, alpha)
