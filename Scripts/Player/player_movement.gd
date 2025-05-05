extends CharacterBody2D

@export var movement_speed := 500.0
@export var dash_force := 5000.0
@export var dash_duration := 0.1
@export var sword_scene: PackedScene = preload("res://Scripts/Player/sword.tscn")

var can_attack := true

func _physics_process(delta):
	handle_movement(delta)

func handle_movement(delta):
	var input_vector = Vector2(
		Input.get_axis("move_left", "move_right"),
		Input.get_axis("move_up", "move_down")
	).normalized()

	if input_vector != Vector2.ZERO:
		velocity = input_vector * movement_speed
		%AnimatedSprite2D.play("move")

		if not Input.is_action_pressed("Attack") and input_vector.x != 0:
			$AnimatedSprite2D.flip_h = input_vector.x < 0
	else:
		velocity = Vector2.ZERO
		%AnimatedSprite2D.play("idle")

	move_and_slide()

	if Input.is_action_just_pressed("Attack") and can_attack:
		attack()

func attack():
	can_attack = false

	var mouse_pos = get_global_mouse_position()
	var mouse_direction = (mouse_pos - global_position).normalized()
	$AnimatedSprite2D.flip_h = mouse_pos.x < global_position.x

	var target_velocity = mouse_direction * dash_force
	var timer = 0.0

	while timer < dash_duration:
		var delta = get_process_delta_time()
		velocity = velocity.move_toward(target_velocity, 8000 * delta)
		move_and_slide()
		await get_tree().process_frame
		timer += delta

	# Dash sonrası durdur
	velocity = Vector2.ZERO

	# Kılıcı oluştur
	var sword = sword_scene.instantiate()
	get_parent().add_child(sword)
	sword.global_position = global_position
	sword.rotation = mouse_direction.angle()

	await get_tree().create_timer(0.1).timeout
	sword.queue_free()
	can_attack = true
