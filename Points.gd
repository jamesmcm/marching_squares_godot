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
	await %NoiseCoarse.texture.changed
	await %NoiseFine.texture.changed
	var noise_image_coarse = %NoiseCoarse.texture.get_image()
	var noise_image_fine = %NoiseFine.texture.get_image()
	# print(noise_image)
	self.set_grid()
	for j in range(0, self.grid_size):
		for i in range(0, self.grid_size):
			var p = point_scene.instantiate()
			# points_weights.append(0.0)
			var pixel_coarse = noise_image_coarse.get_pixel(i*grid_step, j*grid_step)
			var pixel_fine = noise_image_fine.get_pixel(i*grid_step, j*grid_step)
			points_weights.append(0.9*pixel_coarse.r + (0.1*pixel_fine.r))

			points_pos.append(Vector2(self.position.x + (i*self.grid_step), self.position.y + (j*self.grid_step)))
	self.get_parent().regenerateSet(true)
