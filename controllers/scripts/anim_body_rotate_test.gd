extends Node3D

# Speed of rotation in radians per second
var max_rotation_speed : float = 10.0
var rotation_speed : float = 0.0
var increasing_speed : bool = true  # Determines if the speed is increasing or decreasing

# Update function to apply rotation
func _physics_process(delta: float) -> void:
	# Increase or decrease rotation speed
	if increasing_speed:
		rotation_speed += 5.0 * delta  # Increase speed over time
		if rotation_speed >= max_rotation_speed:
			rotation_speed = max_rotation_speed
			increasing_speed = false  # Start decreasing speed
	else:
		rotation_speed -= 20.0 * delta  # Decrease speed over time
		if rotation_speed <= -max_rotation_speed:
			rotation_speed = -max_rotation_speed
			increasing_speed = true  # Start increasing speed

	# Rotate the body around the Y-axis (up axis)
	rotate_y(rotation_speed * delta)
