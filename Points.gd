extends Node2D

signal regenerate

var grid_size = null
var grid_step = null
var points_weights = Array()


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
# Called when the node enters the scene tree for the first time.
# TODO: Why is this so slow?
# TODO: Replace with point mesh ? or check point co-ords vs. Area2D directly?
func _ready():
	self.set_grid()
	for j in range(0, self.grid_size):
		for i in range(0, self.grid_size):
			var p = point_scene.instantiate()
			points_weights.append(0)
			p.position = Vector2(self.position.x + (i*self.grid_step), self.position.y + (j*self.grid_step))
			p.index = (j*grid_size) + i
			p.circle_added.connect(self.circle_added)
			p.circle_removed.connect(self.circle_removed)
			self.add_child(p)

# TODO: Make this receive a set ?
func circle_added(index):
	# print("Signal circle added: " + str(index))
	points_weights[index] = 1.0
	regenerate.emit()
	
func circle_removed(index):
	# print("Signal circle removed: " + str(index))
	points_weights[index] = 0.0
	regenerate.emit()
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
