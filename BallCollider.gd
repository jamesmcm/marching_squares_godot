extends CollisionShape2D

var radius = null

# Called when the node enters the scene tree for the first time.
func _ready():
	self.radius = self.get_parent().radius
	var circle = CircleShape2D.new()
	circle.radius = self.radius
	self.shape = circle
