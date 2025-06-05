extends CharacterBody2D

var speed = 700.0
var follow_speed = 400.0
var mouse_position = null
var accel = 10.0
var decel = 5.0

var normal_zoom = Vector2(1.0, 1.0)
var attack_zoom = Vector2(1.3, 1.3)
var zoom_speed = 3.0

func _ready() -> void:
	add_to_group("player")
	$Camera2D.zoom = normal_zoom

func _physics_process(delta):
	mouse_position = get_global_mouse_position()
	
	if Input.is_action_pressed("move_mouse"):
		PlayerStats.isAttacking = true
		move_fast(delta)
		zoom_camera(attack_zoom, delta)
	else:
		PlayerStats.isAttacking = false
		follow_mouse_slowly(delta)
		zoom_camera(normal_zoom, delta)
		
	velocity = velocity.limit_length(speed if PlayerStats.isAttacking else follow_speed)
	move_and_slide()
	
	camera_offset(delta)
	look_at(mouse_position)

func camera_offset(delta):
	var target_offset_x = (mouse_position.x - global_position.x) / (1920 / 2.0) * 180
	var target_offset_y = (mouse_position.y - global_position.y) / (1080 / 2.0) * 180
	
	$Camera2D.offset.x = lerp($Camera2D.offset.x, target_offset_x, 4.5 * delta)
	$Camera2D.offset.y = lerp($Camera2D.offset.y, target_offset_y, 4.5 * delta)

func move_fast(delta):
	var direction = (mouse_position - position).normalized()
	var target_velocity = direction * speed
	
	velocity.x = lerp(velocity.x, target_velocity.x, accel * delta)
	velocity.y = lerp(velocity.y, target_velocity.y, accel * delta)

func follow_mouse_slowly(delta):
	var direction = (mouse_position - position).normalized()
	var target_velocity = direction * follow_speed
	
	var slow_accel = accel * 0.6
	velocity.x = lerp(velocity.x, target_velocity.x, slow_accel * delta)
	velocity.y = lerp(velocity.y, target_velocity.y, slow_accel * delta)

func zoom_camera(target_zoom: Vector2, delta):
	$Camera2D.zoom.x = lerp($Camera2D.zoom.x, target_zoom.x, zoom_speed * delta)
	$Camera2D.zoom.y = lerp($Camera2D.zoom.y, target_zoom.y, zoom_speed * delta)

func _on_enemy_kill_area_area_entered(area: Area2D) -> void:
	if area.get_parent().is_in_group("enemies") and PlayerStats.isAttacking == true:
		area.get_parent().queue_free()
