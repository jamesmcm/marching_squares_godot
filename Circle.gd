extends Sprite2D

var radius = null


# Called when the node enters the scene tree for the first time.
func _ready():
	self.radius = self.get_parent().radius
	pass # Replace with function body.

func _draw():
	self.radius = self.get_parent().radius
	draw_circle(self.position, self.radius, Color.WHEAT)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func reset_colour(colour: Color):
	self.colour = colour
	self.queue_redraw()

func reset_radius(r: float):
	self.radius = r
	self.queue_redraw()
