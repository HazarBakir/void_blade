extends Node2D

@onready var enemy = preload("res://Scenes/enemy_lvl_1_ranger.tscn")
@onready var spawn_timer: Timer = $Timer
var min_spawn_time = 2.0
var max_spawn_time = 5.0

func _ready():
	spawn_timer.one_shot = true
	start_random_spawn_timer()

func start_random_spawn_timer():
	var random_time = randf_range(min_spawn_time, max_spawn_time)
	spawn_timer.wait_time = random_time
	spawn_timer.start()

func _on_timer_timeout() -> void:
	if enemy == null:
		print("Error: Enemy scene failed to preload")
		return

	var entity = enemy.instantiate()
	if entity == null:
		print("Error: Failed to instantiate enemy")
		return

	entity.position = position
	
	var random_offset = Vector2(randf_range(-50, 50), randf_range(-50, 50))
	entity.position += random_offset

	var enemies_node = get_tree().current_scene.get_node("enemies")
	if enemies_node:
		enemies_node.add_child(entity)
		start_random_spawn_timer()
	else:
		print("enemies node is null")
