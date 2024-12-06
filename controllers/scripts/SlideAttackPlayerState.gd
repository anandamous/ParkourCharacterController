class_name SlideAttackPlayerState extends PlayerMovementState

@export var SPEED : float = 4.0
@export var ACCELERATION : float = 0.1
@export var DECELERATION : float = 0.25

func enter(previous_state) -> void:
	pass

func exit() -> void:
	pass

func update(delta):
	
	PLAYER.set_movement_speed(SPEED)
	PLAYER.update_movement(ACCELERATION, DECELERATION, delta)
	PLAYER.update_velocity()
	
	if Input.is_action_just_pressed("melee"):
		print("RAHHHH")
		PLAYER.velocity.y -= 10.0
		
	if PLAYER.is_on_floor():
		transition.emit("IdlePlayerState")
