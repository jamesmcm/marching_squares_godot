extends Area2D


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _input(event):
	if event is InputEventMouseMotion:
		self.position = get_viewport().get_mouse_position() - get_tree().get_root().get_child(0).position
		if Input.is_action_pressed("paint_circle"):
			for node in self.get_overlapping_areas():
				node.enable_point()
		elif Input.is_action_pressed("unpaint_circle"):
			for node in self.get_overlapping_areas():
				node.disable_point()
	else:
		if event.is_action_pressed("paint_circle"):
			for node in self.get_overlapping_areas():
				node.enable_point()
		if event.is_action_pressed("unpaint_circle"):
			for node in self.get_overlapping_areas():
				node.disable_point()
			
