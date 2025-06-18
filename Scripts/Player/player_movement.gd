extends CharacterBody2D
@onready var health_component: HealthComponent = $HealthComponent
@onready var hitbox_component: HitboxComponent = $HitboxComponent
@onready var explode_particle: GPUParticles2D = $"Explode Particle"
@onready var camera: Camera2D = $Camera2D
@onready var sprite: Sprite2D = $Sprite2D
@onready var marker_2d: Marker2D = $Marker2D

var is_alive: bool = true
var is_attacking: bool
var speed: float = 850.0
var follow_speed: float = 560.0
var mouse_position: Vector2
var accel: float = 10.0
var decel: float = 5.0
var normal_zoom: Vector2 = Vector2(1.0, 1.0)
var attack_zoom: Vector2 = Vector2(1.3, 1.3)
var zoom_speed: float = 3.0
var attack_damage : float = 10.0
var self_damage: float = 10.0

const SCREEN_WIDTH: float = 1920.0
const SCREEN_HEIGHT: float = 1080.0
const CAMERA_OFFSET_FACTOR: float = 180.0
const CAMERA_LERP_SPEED: float = 4.5
const SLOW_ACCEL_MULTIPLIER: float = 0.6

func _on_ready() -> void:
	add_to_group("player")
	camera.zoom = normal_zoom

func _physics_process(delta: float) -> void:
	if health_component.is_alive == false:
		is_alive = false
	mouse_position = get_global_mouse_position()
	
	if is_alive:
		_handle_movement_input(delta)
		_apply_movement()
		_update_camera(delta)
		_update_rotation()
	else:
		_trigger_death()

func _handle_movement_input(delta: float) -> void:
	if Input.is_action_pressed("move_mouse"):
		is_attacking = true
		_move_fast(delta)
		_zoom_camera(attack_zoom, delta)
	else:
		is_attacking = false
		_follow_mouse_slowly(delta)
		_zoom_camera(normal_zoom, delta)

func _apply_movement() -> void:
	var max_speed = speed if is_attacking else follow_speed
	velocity = velocity.limit_length(max_speed)
	move_and_slide()

func _update_camera(delta: float) -> void:
	_update_camera_offset(delta)

func _update_rotation() -> void:
	look_at(mouse_position)

func _move_fast(delta: float) -> void:
	var direction = (mouse_position - position).normalized()
	var target_velocity = direction * speed
	
	velocity.x = lerp(velocity.x, target_velocity.x, accel * delta)
	velocity.y = lerp(velocity.y, target_velocity.y, accel * delta)

func _follow_mouse_slowly(delta: float) -> void:
	var direction = (mouse_position - position).normalized()
	var target_velocity = direction * follow_speed
	
	var slow_accel = accel * SLOW_ACCEL_MULTIPLIER
	velocity.x = lerp(velocity.x, target_velocity.x, slow_accel * delta)
	velocity.y = lerp(velocity.y, target_velocity.y, slow_accel * delta)

func _update_camera_offset(delta: float) -> void:
	var target_offset_x = (mouse_position.x - global_position.x) / (SCREEN_WIDTH / 2.0) * CAMERA_OFFSET_FACTOR
	var target_offset_y = (mouse_position.y - global_position.y) / (SCREEN_HEIGHT / 2.0) * CAMERA_OFFSET_FACTOR
	
	camera.offset.x = lerp(camera.offset.x, target_offset_x, CAMERA_LERP_SPEED * delta)
	camera.offset.y = lerp(camera.offset.y, target_offset_y, CAMERA_LERP_SPEED * delta)

func _zoom_camera(target_zoom: Vector2, delta: float) -> void:
	camera.zoom.x = lerp(camera.zoom.x, target_zoom.x, zoom_speed * delta)
	camera.zoom.y = lerp(camera.zoom.y, target_zoom.y, zoom_speed * delta)

func _trigger_death() -> void:
	if not sprite == null:
		$Camera2D.screen_shake(25, 3)
		explode_particle.set_position(marker_2d.position)
		explode_particle.emitting = true
		sprite.queue_free()


func _is_enemy_area(area: Area2D) -> bool:
	return area.get_parent().is_in_group("enemies")


func _on_area_entered(area: Area2D) -> void:
	if area is HitboxComponent:
		var hitbox: HitboxComponent = area
		var attack = Attack.new()
		attack.attack_damage = attack_damage
		hitbox.damage(attack)
		var enemy = area.get_parent()
		if is_attacking:
			$Camera2D.screen_shake(8, 0.15)
		else:
			if area.get_parent().is_in_group("enemies"):
				health_component.current_health = 0
			attack.attack_damage = self_damage
			hitbox_component.damage(attack)
			
