extends PanelContainer

@onready var property_container = %VBoxContainer

# var property
var frames_per_second : String

# Called when the node enters the scene tree for the first time.
func _ready():
	
	# Set global reference to self in Global Singleton
	Global.debug = self
	
	# Hide Debug Panel on load
	visible = false
	
	#add_debug_property("FPS",frames_per_second)

func _process(delta):
	if visible:
		# Use delta time to get approx frames per second and round to two decimal places
		frames_per_second = "%.2f" % (1.0/delta) # Gets frames per second every frame (thing in front means we want to show our float with two decimal places at all times)
		#property.text = property.name + ": " + frames_per_second
		Global.debug.add_property("FPS", Global.debug.frames_per_second, 1)

func _input(event):
	# Toggle debug panel
	if event.is_action_pressed("debug"):
		visible = !visible

func add_property(title: String, value, order):
	var target
	target = property_container.find_child(title, true, false) # Try to find Label node with same name
	if !target: # If there is no current Label node for property
		target = Label.new() # Create new label node
		property_container.add_child(target) # Add new node as child to Vbox container
		target.name = title # Set name to title
		target.text = target.name + ": " + str(value) # Set text value
	elif visible:
		target.text = title + ": " + str(value) # Update text value
		property_container.move_child(target,order) # Reorder properly based on given order value
		

## Callable function to add new debug property
#func add_debug_property(title: String,value):
	#property = Label.new() # Create new Label node
	#property_container.add_child(property) # Add new node as child to VBox container
	#property.name = title # Set name to title
	#property.text = property.name + value
