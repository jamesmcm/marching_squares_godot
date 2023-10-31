extends Node2D

# TODO: Make this resize to screen
@export_range(10,50) var grid_size = 10
@export_range(50,200) var grid_step = 100
@export var regenerate = false : set = regenerateSet


# Called when the node enters the scene tree for the first time.
func _ready():
	# self.get_child(1).regenerate(true)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func regenerateSet(val):
	%MeshInstance.regenerate(true)



func _on_points_regenerate():
	%MeshInstance.regenerate(true)



