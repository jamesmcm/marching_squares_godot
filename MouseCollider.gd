extends Area2D

var radius = 20

# Called when the node enters the scene tree for the first time.
func _ready():
	self.get_child(0).shape.radius = self.radius
	self.get_child(1).reset_radius(self.radius)
	pass # Replace with function body.

func _on_camera_update(pos):
	self.handle_motion()

func handle_motion():
		self.position = get_viewport().get_mouse_position() + %Camera.position
		if Input.is_action_pressed("paint_circle"):
			for node in self.get_overlapping_areas():
				node.enable_point()
		elif Input.is_action_pressed("unpaint_circle"):
			for node in self.get_overlapping_areas():
				node.disable_point()

func _input(event):
	if event is InputEventMouseMotion:
		self.handle_motion()
	else:
		if event.is_action_pressed("paint_circle"):
			for node in self.get_overlapping_areas():
				node.enable_point()
		if event.is_action_pressed("unpaint_circle"):
			for node in self.get_overlapping_areas():
				node.disable_point()
		if event.is_action_pressed("increase_brush_size"):
			if self.radius < 50:
				self.radius += 5
				self.get_child(0).shape.radius = self.radius
				self.get_child(1).reset_radius(self.radius)
		if event.is_action_pressed("decrease_brush_size"):
			if self.radius > 5:
				self.radius -= 5
				self.get_child(0).shape.radius = self.radius
				self.get_child(1).reset_radius(self.radius)
			
			
