extends Area2D

@export_range(2,20) var circle_size = 2
@export var colour = Color.BLACK
signal circle_added(index)
signal circle_removed(index)

var index: int = 0
var enabled: bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
	# self.get_child(0).set("circle_size", circle_size)
	# self.get_child(0).set("colour", colour)
	self.get_child(0).get("shape").set("radius", circle_size)
	var _err = self.connect("mouse_entered", self._on_mouse_entered)
	pass # Replace with function body.

func init(index: int, parent_node: Node2D):
	self.index = index
	circle_added.connect(parent_node.circle_added)
	circle_removed.connect(parent_node.circle_removed)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
func enable_point():
	if self.enabled:
		return
	self.enabled = true
	# self.get_child(0).reset_colour(Color.GREEN)
	circle_added.emit(self.index)
	# print("Circle " + str(self.index) + " enabled")

func disable_point():
	if not self.enabled:
		return
	self.enabled = false
	# self.get_child(0).reset_colour(Color.BLACK)

	circle_removed.emit(self.index)
	# print("Circle " + str(self.index) + " disabled")

func _on_mouse_entered():
	if Input.is_action_pressed("draw_action"):
		self.enable_point()
	elif Input.is_action_pressed("delete_action"):
		self.disable_point()

func _input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton \
	and event.button_index == MOUSE_BUTTON_LEFT \
	and event.is_pressed():
		self.on_click()

func on_click():
	if self.enabled:
		self.enabled = false
		# self.get_child(0).reset_colour(Color.BLACK)

		circle_removed.emit(self.index)
		# print("Circle " + str(self.index) + " disabled")
	else:
		self.enabled = true
		# self.get_child(0).reset_colour(Color.GREEN)
		circle_added.emit(self.index)
		# print("Circle " + str(self.index) + " enabled")

