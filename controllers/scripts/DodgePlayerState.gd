class_name DodgePlayerState extends PlayerMovementState

@export var SPEED : float = 12.0
@export var ACCELERATION : float = 0.1
@export var DECELERATION : float = 0.25

func enter(previous_state) -> void:
	if ANIMATION.is_playing() and ANIMATION.current_animation == "crouch":
		await ANIMATION.animation_finished
		ANIMATION.pause()
	else:
		ANIMATION.pause()
		
	ANIMATION.play("dodge",-1.0,1.0)
	
	PLAYER.can_dodge = false
	PLAYER.dodge_cooldown_progress = PLAYER.dodge_cooldown
	
	PLAYER.set_movement_speed(SPEED)
	PLAYER.update_wish_dir()
	PLAYER.update_dodge()

func exit() -> void:
	pass
	# ANIMATION.speed_scale = 1.0

func update(delta):
	PLAYER.update_gravity(1.0, delta)
	PLAYER.update_velocity()
	await ANIMATION.animation_finished
	
	transition.emit("SprintingPlayerState")
		
#func set_animation_speed(spd):
	#var alpha = remap(spd, 0.0, Global.player.SPEED_DEFAULT, 0.0, 1.0)
	#ANIMATION.speed_scale = lerp(0.0, TOP_ANIMATION_SPEED, alpha)
