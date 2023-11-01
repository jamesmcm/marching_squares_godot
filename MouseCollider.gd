extends Area2D

signal regenerate

var radius = 20

# Called when the node enters the scene tree for the first time.
func _ready():
	self.get_child(0).shape.radius = self.radius
	self.get_child(1).reset_radius(self.radius)
	pass # Replace with function body.

func _on_camera_update(pos):
	self.handle_motion()

func set_points(enable: bool, smooth: bool):
	for i in range(0, %Points.points_pos.size()):
		var v = %Points.points_pos[i] - self.position
		if v.length() <= self.radius:
			if enable:
				%Points.points_weights[i] = %Points.points_weights[i] + 0.5
			else:
				%Points.points_weights[i] = %Points.points_weights[i] - 0.5
			if %Points.points_weights[i] < 0:
				%Points.points_weights[i] = 0.0
			elif %Points.points_weights[i] > 1.0:
				%Points.points_weights[i] = 1.0
	regenerate.emit()


func handle_motion():
		self.position = get_viewport().get_mouse_position() + %Camera.position
		if Input.is_action_pressed("paint_circle"):
			self.set_points(true, false)
		elif Input.is_action_pressed("unpaint_circle"):
			self.set_points(false, false)

func _input(event):
	if event is InputEventMouseMotion:
		self.handle_motion()
	else:
		if event.is_action_pressed("paint_circle"):
			self.set_points(true, false)
		if event.is_action_pressed("unpaint_circle"):
			self.set_points(false, false)
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
