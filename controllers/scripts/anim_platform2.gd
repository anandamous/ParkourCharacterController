extends AnimatableBody3D

# Variables to control movement
var speed: float = 5.0  # Movement speed
var distance: float = 5.0  # Distance to travel back and forth
var direction: int = -1  # Direction of movement, 1 = forward, -1 = backward
var start_position: Vector3

# Called when the node enters the scene tree for the first time
func _ready():
	start_position = position  # Save the initial position

# Called every frame
func _physics_process(delta: float):
	# Move the platform based on direction and speed
	position.x += direction * speed * delta

	# Reverse direction when the platform moves too far
	if position.x > start_position.x + distance:
		direction = -1  # Move backward
	elif position.x < start_position.x - distance:
		direction = 1  # Move forward
