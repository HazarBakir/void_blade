extends CharacterBody2D
const bullet = preload("res://scenes/bullet.tscn")
@onready var game_scene = get_node("/root/game_scene")
var target: CharacterBody2D = null
var speed = 250.0
var original_speed = 250.0
var accel = 8.0
var decel = 5.0 
var current_speed = 0.0


@onready var shoot_timer: Timer = $Timer
var min_shoot_interval = 1.0
var max_shoot_interval = 3.0
var player_distance_threshold = 500.0
var can_shoot = true

func _ready() -> void:
	add_to_group("enemies")
	find_player()
	setup_random_shooting()

func setup_random_shooting():
	shoot_timer.one_shot = true
	shoot_timer.timeout.connect(_on_shoot_timer_timeout)
	start_random_shoot_timer()

func start_random_shoot_timer():
	var random_interval = randf_range(min_shoot_interval, max_shoot_interval)
	shoot_timer.wait_time = random_interval
	shoot_timer.start()

func find_player():
	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		target = players[0] as CharacterBody2D
		 		
func _physics_process(delta):
	if target == null or not is_instance_valid(target):
		find_player()
		return
		
	move_to_player(delta)
	look_at(target.position)
	move_and_slide()
	
func should_shoot() -> bool:
	if not can_shoot or target == null:
		return false
	
	# Check distance to player
	var distance_to_player = global_position.distance_to(target.global_position)
	if distance_to_player > player_distance_threshold:
		return false
	
	var to_player = (target.global_position - global_position).normalized()
	var forward = Vector2.RIGHT.rotated(rotation)
	var dot_product = to_player.dot(forward)
	
	return dot_product > 0.3
	
func shoot():
	if not should_shoot():
		return
		
	var b = bullet.instantiate()
	if b == null:
		return
		
	b.global_transform = $"Muzzle-Shoot_Point".global_transform
	b.target = target
	game_scene.add_child(b)
	
	can_shoot = false
	await get_tree().create_timer(0.2).timeout
	can_shoot = true
	
func _on_shoot_timer_timeout() -> void:
	shoot()
	start_random_shoot_timer()
	
func move_to_player(delta):
	if target == null:
		return
		
	var direction = (target.position - position).normalized()
	if speed == 0:
		current_speed = lerp(current_speed, 0.0, decel * delta)
	else:
		current_speed = lerp(current_speed, speed, accel * delta)
	
	var target_velocity = direction * current_speed
	velocity = target_velocity
