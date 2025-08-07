extends Node2D
class_name WaveManager

signal wave_started(wave_number: int)
signal wave_completed(wave_number: int)
signal all_waves_completed()

@onready var spawn_timer: Timer
@onready var wave_timer: Timer
@onready var horde_delay_timer: Timer
@onready var wave_check_timer: Timer
@onready var enemies_container: Node = get_tree().current_scene.get_node("enemies")
@onready var player: CharacterBody2D = get_tree().get_first_node_in_group("player")

@export_group("Wave System")
@export var waves: Array[ScriptableWave] = []
@export var wave_break_duration: float = 5.0

@export_group("Spawn Settings")
@export var spawn_radius: float = 700.0
@export var min_spawn_distance: float = 300.0
@export var max_enemies_at_once: int = 15

var current_wave_index: int = -1
var current_wave: ScriptableWave
var enemies_spawned_in_wave: int = 0
var hordes_spawned: int = 0
var is_wave_active: bool = false
var is_spawning_horde: bool = false
var tutorial_completed: bool = false
var all_enemies_spawned: bool = false

const SAVE_FILE_PATH = "user://tutorial_completed.save"

func _ready() -> void:
	await get_tree().process_frame
	
	spawn_timer = Timer.new()
	wave_timer = Timer.new()
	horde_delay_timer = Timer.new()
	wave_check_timer = Timer.new()
	
	add_child(spawn_timer)
	add_child(wave_timer)
	add_child(horde_delay_timer)
	add_child(wave_check_timer)
	
	spawn_timer.timeout.connect(_on_spawn_timer_timeout)
	wave_timer.timeout.connect(_on_wave_timer_timeout)
	horde_delay_timer.timeout.connect(_on_horde_delay_timeout)
	wave_check_timer.timeout.connect(_on_wave_check_timeout)
	
	wave_check_timer.wait_time = 1.0
	
	if is_tutorial_already_completed():
		tutorial_completed = true
		start_wave_system()
		return
	
	var tutorial = find_tutorial()
	if tutorial and tutorial.has_signal("tutorial_completed"):
		tutorial.tutorial_completed.connect(_on_tutorial_completed)

func find_tutorial() -> Node:
	var tutorial = get_node_or_null("../../Control/CanvasLayer/tutorial")
	
	if tutorial == null:
		var scene_root = get_tree().current_scene
		tutorial = scene_root.find_child("tutorial", true, false)
	
	if tutorial == null:
		tutorial = find_tutorial_node(get_tree().current_scene)
	
	return tutorial

func find_tutorial_node(node: Node) -> Node:
	if node.name == "tutorial":
		return node
	
	for child in node.get_children():
		var result = find_tutorial_node(child)
		if result:
			return result
	
	return null

func is_tutorial_already_completed() -> bool:
	if FileAccess.file_exists(SAVE_FILE_PATH):
		var file = FileAccess.open(SAVE_FILE_PATH, FileAccess.READ)
		if file:
			var completed = file.get_var()
			file.close()
			return completed
	return false

func _on_tutorial_completed() -> void:
	tutorial_completed = true
	await get_tree().create_timer(3.0).timeout
	start_wave_system()

func start_wave_system() -> void:
	if waves.is_empty():
		print("No waves configured!")
		return
	
	start_next_wave()

func start_next_wave() -> void:
	current_wave_index += 1
	
	if current_wave_index >= waves.size():
		all_waves_completed.emit()
		print("All waves completed!")
		return
	
	current_wave = waves[current_wave_index]
	if current_wave == null:
		print("ERROR: Wave ", current_wave_index + 1, " is null!")
		start_next_wave()
		return
	
	enemies_spawned_in_wave = 0
	hordes_spawned = 0
	is_wave_active = true
	is_spawning_horde = false
	all_enemies_spawned = false
	
	print("=== Wave ", current_wave_index + 1, " started! ===")
	print("Duration: ", current_wave.wave_duration)
	print("Enemy Count: ", current_wave.enemy_count)
	print("Horde Prefabs: ", current_wave.horde_prefab.size())
	print("Tutorial Completed: ", tutorial_completed)
	
	wave_started.emit(current_wave_index + 1)
	
	wave_timer.wait_time = current_wave.wave_duration
	wave_timer.start()
	
	wave_check_timer.start()
	

	start_horde_delay()


func _on_wave_check_timeout() -> void:
	if not is_wave_active:
		return

	if enemies_spawned_in_wave >= current_wave.enemy_count:
		all_enemies_spawned = true
		print("All enemies spawned for wave ", current_wave_index + 1, " (", enemies_spawned_in_wave, "/", current_wave.enemy_count, ")")
	

	if all_enemies_spawned and get_alive_enemy_count() == 0:
		print("Wave ", current_wave_index + 1, " completed - all enemies defeated!")
		complete_current_wave()

func get_alive_enemy_count() -> int:
	if not is_enemies_container_valid():
		return 0
	
	var alive_count = 0
	for enemy in enemies_container.get_children():
		if enemy != null and is_instance_valid(enemy):
			var health_component = enemy.get_node_or_null("HealthComponent")
			if health_component != null and health_component.has_method("is_alive"):
				if health_component.is_alive():
					alive_count += 1
			else:
				alive_count += 1
	
	return alive_count

func start_horde_delay() -> void:
	if not is_wave_active:
		print("ERROR: Wave not active when trying to start horde delay")
		return
	
	print("Starting horde delay: ", current_wave.horde_routine_delay, " seconds")
	horde_delay_timer.wait_time = current_wave.horde_routine_delay
	horde_delay_timer.start()

func _on_horde_delay_timeout() -> void:
	print("Horde delay timeout! Can spawn horde: ", can_spawn_horde())
	if is_wave_active and can_spawn_horde():
		start_spawning_horde()

func can_spawn_horde() -> bool:
	if current_wave == null:
		return false
	
	var total_hordes_needed = ceil(float(current_wave.enemy_count) / float(current_wave.horde_to_spawn))
	return hordes_spawned < total_hordes_needed

func start_spawning_horde() -> void:
	if not can_spawn_horde():
		print("ERROR: Cannot spawn horde")
		return
	
	is_spawning_horde = true
	hordes_spawned += 1
	
	print("=== Starting horde ", hordes_spawned, " ===")
	print("Spawn interval: ", current_wave.horde_spawn_interval)
	
	spawn_timer.wait_time = current_wave.horde_spawn_interval
	spawn_timer.start()

func spawn_enemy() -> void:
	if not can_spawn():
		return
	
	check_and_manage_enemy_count()
	
	var enemy_instance = create_enemy_instance()
	if enemy_instance == null:
		return
	
	position_enemy_in_radius(enemy_instance)
	add_enemy_to_scene(enemy_instance)
	
	enemies_spawned_in_wave += 1
	print("Enemy spawned: ", enemies_spawned_in_wave, "/", current_wave.enemy_count)
	
	var enemies_in_current_horde = min(current_wave.horde_to_spawn, 
		current_wave.enemy_count - (hordes_spawned - 1) * current_wave.horde_to_spawn)
	
	var enemies_spawned_in_current_horde = enemies_spawned_in_wave - (hordes_spawned - 1) * current_wave.horde_to_spawn
	
	if enemies_spawned_in_current_horde >= enemies_in_current_horde:
		finish_current_horde()

func finish_current_horde() -> void:
	is_spawning_horde = false
	spawn_timer.stop()
	
	print("Horde ", hordes_spawned, " finished")
	
	if can_spawn_horde():
		start_horde_delay()
	else:
		print("All hordes spawned for wave ", current_wave_index + 1)

func can_spawn() -> bool:
	if current_wave == null:
		return false
		
	var player_alive = player != null and player.get_node("HealthComponent").is_alive
	var container_valid = is_enemies_container_valid()
	var wave_active = is_wave_active and is_spawning_horde
	var enemies_remaining = enemies_spawned_in_wave < current_wave.enemy_count
	
	return player_alive and container_valid and tutorial_completed and wave_active and enemies_remaining

func is_enemies_container_valid() -> bool:
	return enemies_container != null and is_instance_valid(enemies_container)

func create_enemy_instance() -> Node:
	if current_wave == null or current_wave.horde_prefab.is_empty():
		print("No enemy prefabs configured for current wave!")
		return null
	
	var random_index = randi() % current_wave.horde_prefab.size()
	var enemy_scene = current_wave.horde_prefab[random_index]
	
	if enemy_scene == null:
		print("Enemy scene is null at index: ", random_index)
		return null
	
	var enemy_instance = enemy_scene.instantiate()
	if enemy_instance == null:
		print("Failed to instantiate enemy scene")
		return null
	
	return enemy_instance

func position_enemy_in_radius(enemy_instance: Node) -> void:
	enemy_instance.position = player.position + get_random_position_in_radius()

func get_random_position_in_radius() -> Vector2:
	var angle = randf() * 2 * PI
	var distance = randf_range(min_spawn_distance, spawn_radius)
	
	return Vector2(
		cos(angle) * distance,
		sin(angle) * distance
	)

func add_enemy_to_scene(enemy_instance: Node) -> void:
	if not is_enemies_container_valid():
		enemy_instance.queue_free()
		return
	
	enemies_container.add_child(enemy_instance)

func check_and_manage_enemy_count() -> void:
	if not is_enemies_container_valid():
		return
	
	var current_enemy_count = enemies_container.get_child_count()
	
	if current_enemy_count >= max_enemies_at_once:
		var enemies_to_kill = current_enemy_count - max_enemies_at_once + 1
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
			else:
				enemy.queue_free()

func _on_spawn_timer_timeout() -> void:
	if is_spawning_horde and can_spawn():
		spawn_enemy()

func _on_wave_timer_timeout() -> void:
	print("Wave timer timeout for wave ", current_wave_index + 1)
	print("Enemies spawned: ", enemies_spawned_in_wave, "/", current_wave.enemy_count)
	print("Alive enemies: ", get_alive_enemy_count())
	
	if enemies_spawned_in_wave >= current_wave.enemy_count and get_alive_enemy_count() == 0:
		complete_current_wave()
	elif is_wave_active:
		print("Force completing wave due to timeout")
		complete_current_wave()

func complete_current_wave() -> void:
	if not is_wave_active:
		return
	
	is_wave_active = false
	is_spawning_horde = false
	all_enemies_spawned = false
	spawn_timer.stop()
	wave_timer.stop()
	horde_delay_timer.stop()
	wave_check_timer.stop()
	
	print("=== Wave ", current_wave_index + 1, " completed! ===")
	print("Enemies spawned: ", enemies_spawned_in_wave, "/", current_wave.enemy_count)
	print("Remaining enemies: ", get_alive_enemy_count())
	
	wave_completed.emit(current_wave_index + 1)
	
	if current_wave_index + 1 >= waves.size():
		all_waves_completed.emit()
		print("All waves completed!")
		return
	
	print("Waiting ", wave_break_duration, " seconds before next wave...")
	await get_tree().create_timer(wave_break_duration).timeout
	start_next_wave()

func skip_to_wave(wave_number: int) -> void:
	if wave_number > 0 and wave_number <= waves.size():
		current_wave_index = wave_number - 2
		complete_current_wave()

func get_current_wave_info() -> Dictionary:
	return {
		"current_wave": current_wave_index + 1,
		"total_waves": waves.size(),
		"enemies_spawned": enemies_spawned_in_wave,
		"target_enemies": current_wave.enemy_count if current_wave else 0,
		"hordes_spawned": hordes_spawned,
		"is_active": is_wave_active,
		"is_spawning_horde": is_spawning_horde,
		"all_enemies_spawned": all_enemies_spawned,
		"alive_enemies": get_alive_enemy_count(),
		"time_remaining": wave_timer.time_left if is_wave_active else 0.0
	}
