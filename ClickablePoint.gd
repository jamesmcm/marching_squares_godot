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
