extends CharacterBody2D
var speed = 200
var mouse_position = null
 
func _physics_process(delta):
	velocity = Vector2(0, 0)
	mouse_position = get_global_mouse_position()
 
	var direction = (mouse_position - position).normalized()
	velocity = (direction * speed)
	
	#Camera offset
	$Camera2D.offset.x = (mouse_position.x - global_position.x) / (1920 / 2.0) * 140
	$Camera2D.offset.y = (mouse_position.y - global_position.y) / (1080 / 2.0) * 140
	
	move_and_slide()
	look_at(mouse_position)
