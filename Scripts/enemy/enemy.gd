extends CharacterBody2D

@onready var health_component: HealthComponent = $HealthComponent
@onready var hitbox_component: HitboxComponent = $HitboxComponent
@onready var game_scene = get_node("/root/game_scene")
@onready var shoot_timer: Timer = $Timer
@onready var sprite: Sprite2D = $Sprite2D

const BULLET_SCENE = preload("res://scenes/bullet.tscn")

var is_alive: bool = true
var target: CharacterBody2D = null
var can_shoot: bool = true

const ORIGINAL_SPEED: float = 300.0
const ACCELERATION: float = 8.0
const DECELERATION: float = 5.0
const STOP_DISTANCE: float = 300.0
const RESUME_DISTANCE: float = 200.0

const RECOIL_FORCE: float = 500.0
const RECOIL_DURATION: float = 0.4

var speed: float = ORIGINAL_SPEED
var current_speed: float = 0.0
var recoil_velocity: Vector2 = Vector2.ZERO

const MIN_SHOOT_INTERVAL: float = 1.0
const MAX_SHOOT_INTERVAL: float = 3.0
const PLAYER_DISTANCE_THRESHOLD: float = 1000.0
const SHOOT_COOLDOWN: float = 0.2
const SHOOT_ANGLE_THRESHOLD: float = 0.3

func _ready() -> void:
	_initialize_enemy()
	_setup_shooting_system()

func _physics_process(delta: float) -> void:
	if health_component.is_alive == false:
		on_death()
		
	if target.get_node("HealthComponent").is_alive:
		_update_movement_behavior()
		_handle_movement(delta)
		move_and_slide()
		_update_rotation()

func _initialize_enemy() -> void:
	add_to_group("enemies")
	_find_player()

func _setup_shooting_system() -> void:
	shoot_timer.one_shot = true
	shoot_timer.timeout.connect(_on_shoot_timer_timeout)
	_start_random_shoot_timer()

func _start_random_shoot_timer() -> void:
	var random_interval = randf_range(MIN_SHOOT_INTERVAL, MAX_SHOOT_INTERVAL)
	shoot_timer.wait_time = random_interval
	shoot_timer.start()

func _find_player() -> void:
	var player = get_tree().get_nodes_in_group("player")
	if player.size() > 0:
		target = player[0] as CharacterBody2D

func _update_target() -> void:
	if target == null or not is_instance_valid(target):
		_find_player()

func _update_movement_behavior() -> void:
	if target == null:
		return
	
	var distance_to_player = global_position.distance_to(target.global_position)
	
	if distance_to_player < STOP_DISTANCE:
		speed = 0
	elif speed == 0 and distance_to_player > RESUME_DISTANCE:
		speed = ORIGINAL_SPEED

func _handle_movement(delta: float) -> void:
	if target == null or not is_alive:
		return
	
	var direction = (target.global_position - global_position).normalized()
	var target_speed = speed if speed > 0 else 0.0
	var lerp_factor = ACCELERATION if speed > 0 else DECELERATION
	
	current_speed = lerp(current_speed, target_speed, lerp_factor * delta)
	var normal_velocity = direction * current_speed
	
	recoil_velocity = lerp(recoil_velocity, Vector2.ZERO, 4.0 * delta)
	
	if speed == 0:
		velocity = recoil_velocity
	else:
		velocity = normal_velocity

func _update_rotation() -> void:
	if target != null:
		sprite.look_at(target.global_position)

func _should_shoot() -> bool:
	if not can_shoot or target == null:
		return false
	
	var distance_to_player = sprite.global_position.distance_to(target.global_position)
	if distance_to_player > PLAYER_DISTANCE_THRESHOLD:
		return false
	return true

func _apply_recoil() -> void:
	var backward_direction = -Vector2.RIGHT.rotated(sprite.rotation)
	recoil_velocity = backward_direction * RECOIL_FORCE

func _shoot() -> void:
	if not _should_shoot():
		return
	var bullet_instance = BULLET_SCENE.instantiate()
	if bullet_instance == null:
		return
	
	bullet_instance.global_position = $"Sprite2D/Muzzle-Shoot_Point".global_position
	bullet_instance.target = target
	add_child(bullet_instance)
	_apply_recoil()
	_apply_shoot_cooldown()

func _apply_shoot_cooldown() -> void:
	can_shoot = false
	await get_tree().create_timer(SHOOT_COOLDOWN).timeout
	can_shoot = true

func on_death() -> void:
		target.kill_count += 1
		_setup_death_effects()
		queue_free()

func _setup_death_effects() -> void:
	particle_manager.emit_particle("enemy", global_position)

func _on_shoot_timer_timeout() -> void:
	if target.get_node("HealthComponent").is_alive and is_alive:
		_shoot()
		_start_random_shoot_timer()

func _on_hitbox_component_area_entered(area: Area2D) -> void:
	if area.get_parent().is_in_group("player"):
		$AnimationPlayer.play("Hit")
		if not target.is_attacking:
			on_death()
