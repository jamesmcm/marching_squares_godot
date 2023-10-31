extends Camera2D

signal camera_update
# TODO: Get from config
var window_size = Vector2(1920, 1080)
# TODO: Get game world size from level?
@export_range(5,40) var camera_move_speed = 20

func _input(event):
	if Input.is_action_pressed("ui_up"):
		if self.position.y >= camera_move_speed:
			self.position += Vector2(0, -camera_move_speed)
			camera_update.emit(self.position)
	if Input.is_action_pressed("ui_down"):
		if self.position.y <= 2000 - (2*camera_move_speed) - self.window_size.y:
			self.position += Vector2(0, camera_move_speed)
			camera_update.emit(self.position)
	if Input.is_action_pressed("ui_left"):
		if self.position.x >= camera_move_speed:
			self.position += Vector2(-camera_move_speed, 0)
			camera_update.emit(self.position)
	if Input.is_action_pressed("ui_right"):
		if self.position.x <= 2000 - (2*camera_move_speed) - self.window_size.x:
			self.position += Vector2(camera_move_speed, 0)
			camera_update.emit(self.position)
