extends Sprite2D

@export_range(4,20) var circle_size = 5
@export var colour = Color.BLACK


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _draw():
	draw_circle(self.position, self.circle_size, self.colour)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func reset_colour(colour: Color):
	self.colour = colour
	self.queue_redraw()
