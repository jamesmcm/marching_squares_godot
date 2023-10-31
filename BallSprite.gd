extends Sprite2D

var circle_size = 20
@export var colour = Color.BLUE_VIOLET


# Called when the node enters the scene tree for the first time.
func _ready():
	pass


func _draw():
	draw_circle(self.position, self.circle_size, self.colour)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# TODO: Delete when out of bounds
	pass

func reset_colour(colour: Color):
	self.colour = colour
	self.queue_redraw()
