class_name DivePlayerState extends PlayerMovementState

func enter(previous_state) -> void:
	PLAYER.velocity.y = 0.0
	
	PLAYER.can_dive = false
	PLAYER.dive_cooldown_progress = PLAYER.dive_cooldown

func exit() -> void:
	pass

func update(delta):
	PLAYER.update_gravity(5.0, delta)
	PLAYER.update_velocity()

	if PLAYER.is_on_floor():	
		transition.emit("IdlePlayerState")
