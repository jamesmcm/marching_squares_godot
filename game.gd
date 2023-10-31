extends Node2D

# TODO: Make this resize to screen
@export_range(10,1000) var grid_size = 100
@export_range(5,200) var grid_step = 10
@export var regenerate = false : set = regenerateSet
var pending_regenerate = false

var ball_scene = preload("res://falling_ball.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	print("test")
	print(self.grid_size)
	# self.get_child(1).regenerate(true)
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if self.pending_regenerate:
		%MeshInstance.regenerate(true)
		self.pending_regenerate = false
	pass


func _input(event):
	if event.is_action_released("create_ball"):
		var b = ball_scene.instantiate()
		b.position = get_viewport().get_mouse_position() - self.position
		self.add_child(b)




func regenerateSet(val):
	self.pending_regenerate = true



func _on_points_regenerate():
	self.pending_regenerate = true



