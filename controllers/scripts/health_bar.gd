extends TextureProgressBar

@export var speed : float = 2.0 # Speed of the bounce

var direction : int = 1 # Direction of the progress (1 = forward, -1 = backward)

func _ready():
	value = min_value # Start at the minimum value
	force_update_transform()

func _process(delta):
	# Update the progress value based on the speed and direction
	value += direction * speed * delta

	# Check if we need to reverse the direction
	if value >= max_value:
		value = max_value
		direction = -1 # Start moving backward
	elif value <= min_value:
		value = min_value
		direction = 1 # Start moving forward
