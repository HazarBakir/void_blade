extends CharacterBody2D
var speed = 600
var mouse_position = null

func _ready() -> void:
	add_to_group("player")

func _physics_process(delta):
	mouse_position = get_global_mouse_position()
	if Input.is_action_pressed("move_mouse"):
		move()
	camera_offset()
	look_at(mouse_position)


func camera_offset():
	$Camera2D.offset.x = (mouse_position.x - global_position.x) / (1920 / 2.0) * 140
	$Camera2D.offset.y = (mouse_position.y - global_position.y) / (1080 / 2.0) * 140

func move():
	var direction = (mouse_position - position).normalized()
	velocity = (direction * speed)
	move_and_slide()
