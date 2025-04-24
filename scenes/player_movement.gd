extends AnimatedSprite2D

@export var movement_speed : float = 500
var character_direction : Vector2
var velocity: Vector2 = Vector2.ZERO

func _physics_process(delta):
	character_direction.x = Input.get_axis("move_left","move_right")
	character_direction.y = Input.get_axis("move_up", "move_down")
	character_direction = character_direction.normalized()

	# Flip sprite based on direction
	if character_direction.x > 0:
		flip_h = false
	elif character_direction.x < 0:
		flip_h = true

	# Movement and animation
	if character_direction != Vector2.ZERO:
		velocity = character_direction * movement_speed
		if animation != "move":
			animation = "move"
	else:
		velocity = velocity.move_toward(Vector2.ZERO, movement_speed * delta)
		if animation != "idle":
			animation = "idle"

	position += velocity * delta
