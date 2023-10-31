extends Sprite2D


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func _draw():
	var rect = Rect2(self.get_global_position(), self.get_parent().get_parent().shape.size)
	print(rect)
	draw_rect(rect, Color.BLACK)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
