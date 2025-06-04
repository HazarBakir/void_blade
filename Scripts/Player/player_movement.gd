extends CharacterBody2D

var speed = 700.0
var mouse_position = null
var accel = 10.0
var decel = 5.0

func _ready() -> void:
	add_to_group("player")

func _physics_process(delta):
	mouse_position = get_global_mouse_position()
	
	if Input.is_action_pressed("move_mouse"):
		move(delta)
	else:
		slow_down(delta)
		
	velocity = velocity.limit_length(speed)
	move_and_slide()
	
	camera_offset(delta)
	look_at(mouse_position)

func camera_offset(delta):
	var target_offset_x = (mouse_position.x - global_position.x) / (1920 / 2.0) * 140
	var target_offset_y = (mouse_position.y - global_position.y) / (1080 / 2.0) * 140
	
	$Camera2D.offset.x = lerp($Camera2D.offset.x, target_offset_x, 4.5 * delta)
	$Camera2D.offset.y = lerp($Camera2D.offset.y, target_offset_y, 4.5 * delta)

func move(delta):
	var direction = (mouse_position - position).normalized()
	var target_velocity = direction * speed
	
	velocity.x = lerp(velocity.x, target_velocity.x, accel * delta)
	velocity.y = lerp(velocity.y, target_velocity.y, accel * delta)

func slow_down(delta):
	velocity.x = lerp(velocity.x, 0.0, decel * delta)
	velocity.y = lerp(velocity.y, 0.0, decel * delta)

func _on_enemy_kill_area_area_entered(area: Area2D) -> void:
	if area.is_in_group("enemies"):
		area.queue_free()
	elif area.get_parent().is_in_group("enemies"):
		area.get_parent().queue_free()
