extends RigidBody2D

var radius = 20

# Called when the node enters the scene tree for the first time.
func _ready():
	self.get_child(0).radius = self.radius
	self.get_child(1).circle_size = self.radius
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
