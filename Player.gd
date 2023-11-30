extends CharacterBody2D

var rect = Rect2(Vector2(0,0), Vector2(60,30))
const SPEED = 300.0
const JUMP_VELOCITY = -400.0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func _ready():
	var cshape = RectangleShape2D.new()
	cshape.size = rect.size
	print(rect.size)
	print(cshape.size)
	self.get_child(0).shape = cshape
	self.get_child(0).position = rect.size / 2.0 

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta

	# Handle Jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction = Input.get_axis("ui_left", "ui_right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()


func _draw():
	draw_rect(rect, Color.BLUE_VIOLET)

