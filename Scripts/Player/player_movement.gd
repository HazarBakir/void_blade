extends CharacterBody2D

var speed = 200
var mouse_position = null
 
func _physics_process(delta):
	
	velocity = Vector2(0, 0)
	mouse_position = get_global_mouse_position()
 
	var direction = (mouse_position - position).normalized()
	velocity = (direction * speed)
	
	move_and_slide()
	look_at(mouse_position)
