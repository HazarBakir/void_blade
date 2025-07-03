extends CharacterBody2D

@onready var explode_particle: GPUParticles2D = $"Explode Particle"
@onready var game_scene = get_node("/root/game_scene")
@onready var shoot_timer: Timer = $Timer
@onready var sprite: Sprite2D = $Sprite2D
@onready var muzzle_point = $"Muzzle-Shoot_Point"
@onready var death_timer: Timer = $"Explode Particle/Timer"

const BULLET_SCENE = preload("res://scenes/bullet.tscn")

var is_alive: bool = true
var target: CharacterBody2D = null
var can_shoot: bool = true

const ORIGINAL_SPEED: float = 350.0
const ACCELERATION: float = 8.0
const DECELERATION: float = 5.0
const STOP_DISTANCE: float = 180.0
const RESUME_DISTANCE: float = 300.0

var speed: float = ORIGINAL_SPEED
var current_speed: float = 0.0

const MIN_SHOOT_INTERVAL: float = 1.0
const MAX_SHOOT_INTERVAL: float = 3.0
const PLAYER_DISTANCE_THRESHOLD: float = 1000.0
const SHOOT_COOLDOWN: float = 0.2
const SHOOT_ANGLE_THRESHOLD: float = 0.3

func _ready() -> void:
	_initialize_enemy()
	_setup_shooting_system()

func _physics_process(delta: float) -> void:
	if not PlayerStats.is_alive():
		return
		
	_update_target()
	if target == null:
		return
		
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
	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		target = players[0] as CharacterBody2D

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
<<<<<<< Updated upstream
	velocity = direction * current_speed
=======
	var normal_velocity = direction * current_speed
	
	recoil_velocity = lerp(recoil_velocity, Vector2.ZERO, 6.0 * delta)
	
	if speed == 0:
		velocity = recoil_velocity
	else:
		velocity = normal_velocity
>>>>>>> Stashed changes

func _update_rotation() -> void:
	if target != null:
		look_at(target.global_position)

func _should_shoot() -> bool:
	if not can_shoot or target == null:
		return false
	
	var distance_to_player = global_position.distance_to(target.global_position)
	if distance_to_player > PLAYER_DISTANCE_THRESHOLD:
		return false
	
	return _is_facing_target()

func _is_facing_target() -> bool:
	var to_player = (target.global_position - global_position).normalized()
	var forward = Vector2.RIGHT.rotated(rotation)
	var dot_product = to_player.dot(forward)
	return dot_product > SHOOT_ANGLE_THRESHOLD

func _shoot() -> void:
	if not _should_shoot():
		return
	
	var bullet_instance = BULLET_SCENE.instantiate()
	if bullet_instance == null:
		return
	
	bullet_instance.global_transform = muzzle_point.global_transform
	bullet_instance.target = target
	game_scene.add_child(bullet_instance)
	
	_apply_shoot_cooldown()

func _apply_shoot_cooldown() -> void:
	can_shoot = false
	await get_tree().create_timer(SHOOT_COOLDOWN).timeout
	can_shoot = true

func on_death() -> void:
	if not is_alive:
		return
	
	_trigger_death_sequence()

func _trigger_death_sequence() -> void:
	is_alive = false
	_setup_death_effects()
	_cleanup_sprite()

func _setup_death_effects() -> void:
<<<<<<< Updated upstream
	explode_particle.position = muzzle_point.position
	explode_particle.emitting = true
	death_timer.start()

func _cleanup_sprite() -> void:
	if sprite != null:
		sprite.queue_free()

=======
	particle_manager.emit_particle("enemy", position)
	
>>>>>>> Stashed changes
func _on_shoot_timer_timeout() -> void:
	if PlayerStats.is_alive() and is_alive:
		_shoot()
		_start_random_shoot_timer()

func _on_death_timer_timeout() -> void:
	queue_free()
