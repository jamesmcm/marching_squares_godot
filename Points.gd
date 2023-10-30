extends Node2D

signal regenerate

var grid_size = 10
var grid_step = 100
var points_status = Array()

var point_scene = preload("res://clickable_point.tscn")

func set_grid():
	var root_node = get_tree().get_root()
	var root_grid_size = root_node.get("grid_size")
	if root_grid_size != null:
		self.grid_size = root_grid_size
	var root_grid_step = root_node.get("grid_step")
	if root_grid_step != null:
		self.grid_step = root_grid_step
# Called when the node enters the scene tree for the first time.
func _ready():
	for j in range(0, grid_size):
		for i in range(0, grid_size):
			var p = point_scene.instantiate()
			points_status.append(false)
			p.position = Vector2(self.position.x + (i*self.grid_step), self.position.y + (j*self.grid_step))
			p.init((j*grid_size) + i, self)
			self.add_child(p)
			# points.append()


func circle_added(index):
	print("Signal circle added: " + str(index))
	points_status[index] = true
	regenerate.emit()
	
func circle_removed(index):
	print("Signal circle removed: " + str(index))
	points_status[index] = false
	regenerate.emit()
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
