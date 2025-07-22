extends Node2D

@onready var spawn_timer: Timer = $Timer
@onready var enemies_container: Node = get_tree().current_scene.get_node("enemies")
@onready var player: CharacterBody2D = get_tree().get_first_node_in_group("player")

const ENEMY_SCENE = preload("res://scenes/enemy_lvl_1_ranger.tscn")
const MIN_SPAWN_TIME: float = 1.0
const MAX_SPAWN_TIME: float = 2.5

const SPAWN_RADIUS: float = 700.0
const MIN_SPAWN_DISTANCE: float = 300.0 

const MAX_ENEMIES: int = 15

func _ready() -> void:
	setup_spawn_timer()

func setup_spawn_timer() -> void:
	start_random_spawn_timer()

func start_random_spawn_timer() -> void:
	var random_time = randf_range(MIN_SPAWN_TIME, MAX_SPAWN_TIME)
	spawn_timer.wait_time = random_time
	spawn_timer.start()

func spawn_enemy() -> void:
	
	if not can_spawn():
		return
	
	check_and_manage_enemy_count()
	
	var enemy_instance = create_enemy_instance()
	if enemy_instance == null:
		print("Failed to create enemy instance")
		return
	
	position_enemy_in_radius(enemy_instance)
	add_enemy_to_scene(enemy_instance)
	start_random_spawn_timer()

func can_spawn() -> bool:
	var player_alive = player != null and player.get_node("HealthComponent").is_alive
	var container_valid = is_enemies_container_valid()
	
	return player_alive and container_valid

func is_enemies_container_valid() -> bool:
	return enemies_container != null and is_instance_valid(enemies_container)

func create_enemy_instance() -> Node:
	if ENEMY_SCENE == null:
		push_error("Enemy scene failed to preload")
		return null
	
	var enemy_instance = ENEMY_SCENE.instantiate()
	if enemy_instance == null:
		push_error("Failed to instantiate enemy")
		return null
	
	return enemy_instance

func position_enemy_in_radius(enemy_instance: Node) -> void:
	enemy_instance.position = player.position + get_random_position_in_radius()

func get_random_position_in_radius() -> Vector2:
	var angle = randf() * 2 * PI
	var distance = randf_range(MIN_SPAWN_DISTANCE, SPAWN_RADIUS)
	
	return Vector2(
		cos(angle) * distance,
		sin(angle) * distance
	)

func add_enemy_to_scene(enemy_instance: Node) -> void:
	if not is_enemies_container_valid():
		push_error("Enemies container is not available")
		enemy_instance.queue_free()
		return
	
	enemies_container.add_child(enemy_instance)

func check_and_manage_enemy_count() -> void:
	if not is_enemies_container_valid():
		return
	
	var current_enemy_count = enemies_container.get_child_count()
	
	if current_enemy_count >= MAX_ENEMIES:
		var enemies_to_kill = current_enemy_count - MAX_ENEMIES + 1
		kill_oldest_enemies(enemies_to_kill)

func kill_oldest_enemies(count: int) -> void:
	if not is_enemies_container_valid():
		return
	
	var enemies = enemies_container.get_children()
	
	for i in range(min(count, enemies.size())):
		var enemy = enemies[i]
		if enemy != null and is_instance_valid(enemy):
			if enemy.has_method("on_death"):
				enemy.on_death()
				print("enemy died")
			else:
				enemy.queue_free()

func _on_timer_timeout() -> void:
	if player != null and player.get_node("HealthComponent").is_alive:
		spawn_enemy()
