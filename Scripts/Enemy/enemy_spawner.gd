extends Node2D

@onready var spawn_timer: Timer = $Timer
@onready var enemies_container: Node = get_tree().current_scene.get_node("enemies")
var target: CharacterBody2D = null

const ENEMY_SCENE = preload("res://Scenes/enemy_lvl_1_ranger.tscn")
const MIN_SPAWN_TIME: float = 2.0
const MAX_SPAWN_TIME: float = 5.0
const SPAWN_OFFSET_RANGE: float = 150.0

func _ready() -> void:
	_find_player()
	_setup_spawn_timer()

func _setup_spawn_timer() -> void:
	spawn_timer.one_shot = true
	_start_random_spawn_timer()

func _start_random_spawn_timer() -> void:
	var random_time = randf_range(MIN_SPAWN_TIME, MAX_SPAWN_TIME)
	spawn_timer.wait_time = random_time
	spawn_timer.start()

func _spawn_enemy() -> void:
	if not _can_spawn():
		return
	
	var enemy_instance = _create_enemy_instance()
	if enemy_instance == null:
		return
	
	_position_enemy(enemy_instance)
	_add_enemy_to_scene(enemy_instance)
	_start_random_spawn_timer()

func _can_spawn() -> bool:
	return target.get_node("HealthComponent").is_alive and _is_enemies_container_valid()

func _is_enemies_container_valid() -> bool:
	return enemies_container != null and is_instance_valid(enemies_container)

func _create_enemy_instance() -> Node:
	if ENEMY_SCENE == null:
		push_error("Enemy scene failed to preload")
		return null
	
	var enemy_instance = ENEMY_SCENE.instantiate()
	if enemy_instance == null:
		push_error("Failed to instantiate enemy")
		return null
	
	return enemy_instance

func _position_enemy(enemy_instance: Node) -> void:
	enemy_instance.position = position + _get_random_offset()

func _get_random_offset() -> Vector2:
	return Vector2(
		randf_range(-SPAWN_OFFSET_RANGE, SPAWN_OFFSET_RANGE),
		randf_range(-SPAWN_OFFSET_RANGE, SPAWN_OFFSET_RANGE)
	)

func _add_enemy_to_scene(enemy_instance: Node) -> void:
	if not _is_enemies_container_valid():
		push_error("Enemies container is not available")
		enemy_instance.queue_free()
		return
	
	enemies_container.add_child(enemy_instance)

func _on_timer_timeout() -> void:
	if target.get_node("HealthComponent").is_alive:
		_spawn_enemy()
	
func _find_player() -> void:
	var player = get_tree().get_nodes_in_group("player")
	if player.size() > 0:
		target = player[0] as CharacterBody2D
