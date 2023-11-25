extends Node2D

var grid_size = null
var grid_step = null
var points_weights = Array()
var points_pos = Array()

var point_scene = preload("res://clickable_point.tscn")

func set_grid():
	var root_node = get_tree().get_root().get_child(0)
	print(root_node.name)
	var root_grid_size = root_node.get("grid_size")
	print(root_grid_size)
	if root_grid_size != null:
		self.grid_size = root_grid_size
	var root_grid_step = root_node.get("grid_step")
	if root_grid_step != null:
		self.grid_step = root_grid_step

func _ready():
	self.set_grid()
	for j in range(0, self.grid_size):
		for i in range(0, self.grid_size):
			var p = point_scene.instantiate()
			points_weights.append(0.0)
			points_pos.append(Vector2(self.position.x + (i*self.grid_step), self.position.y + (j*self.grid_step)))
