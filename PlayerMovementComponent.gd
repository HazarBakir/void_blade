extends Node
class_name PlayerMovementComponent

var player: CharacterBody2D
var mouse_position: Vector2

var speed: float = 1000.0
var follow_speed: float = 560.0
var accel: float = 10.0
const SLOW_ACCEL_MULTIPLIER: float = 0.6

func setup(player_ref: CharacterBody2D) -> void:
	player = player_ref

func handle_movement(delta: float) -> void:
	mouse_position = player.get_global_mouse_position()
	
	handle_movement_input(delta)
	apply_movement()
	update_sprite_rotation(delta)

func handle_movement_input(delta: float) -> void:
	if Input.is_action_pressed("move_mouse"):
		move_fast(delta)
	else:
		follow_mouse_slowly(delta)

func apply_movement() -> void:
	var is_attacking = player.get_is_attacking()
	var max_speed = speed if is_attacking else follow_speed
	player.velocity = player.velocity.limit_length(max_speed)
	player.move_and_slide()

func update_sprite_rotation(delta: float) -> void:
	if player.sprite:
		var rotation_speed = 16.0 if player.get_is_attacking() else 8.0
		player.sprite.rotation += 1.0 * delta * rotation_speed

func move_fast(delta: float) -> void:
	var direction = (mouse_position - player.global_position).normalized()
	var target_velocity = direction * speed
	
	player.velocity.x = lerp(player.velocity.x, target_velocity.x, accel * delta)
	player.velocity.y = lerp(player.velocity.y, target_velocity.y, accel * delta)

func follow_mouse_slowly(delta: float) -> void:
	var direction = (mouse_position - player.global_position).normalized()
	var target_velocity = direction * follow_speed
	
	var slow_accel = accel * SLOW_ACCEL_MULTIPLIER
	player.velocity.x = lerp(player.velocity.x, target_velocity.x, slow_accel * delta)
	player.velocity.y = lerp(player.velocity.y, target_velocity.y, slow_accel * delta)

func get_mouse_position() -> Vector2:
	return mouse_position
