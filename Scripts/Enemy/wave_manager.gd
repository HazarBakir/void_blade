extends Node2D

signal wave_started(wave_number: int)
signal wave_completed(wave_number: int)
signal all_waves_completed()

@onready var enemies_container: Node = get_tree().current_scene.get_node("enemies")
@onready var player: CharacterBody2D = get_tree().get_first_node_in_group("player")
@onready var wave_count: RichTextLabel = $CanvasLayer/RichTextLabel
@onready var game_message: RichTextLabel = $CanvasLayer/GameMessage
@onready var countdown_ui: RichTextLabel = $CanvasLayer/Countdown

@onready var spawn_timer: Timer = $Timers/SpawnTimer
@onready var wave_timer: Timer = $Timers/WaveTimer
@onready var horde_delay_timer: Timer = $Timers/HordeDelayTimer
@onready var wave_check_timer: Timer = $Timers/WaveCheckTimer
@onready var countdown_timer: Timer = $Timers/CountdownTimer
@onready var fight_timer: Timer = $Timers/FightTimer
@onready var wave_break_timer: Timer = $Timers/WaveBreakTimer
@onready var message_timer: Timer = $Timers/MessageTimer

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
var countdown_step: int = 0
var _countdown_callback: Callable

func _ready() -> void:
	_setup_ui()
	_setup_timers()
	_connect_tutorial()

func _setup_ui() -> void:
	wave_count.text = "-"
	game_message.text = ""
	countdown_ui.text = ""

func _setup_timers() -> void:
	wave_check_timer.wait_time = 1.0
	countdown_timer.wait_time = 1.0
	countdown_timer.one_shot = true
	fight_timer.wait_time = 1.5
	fight_timer.one_shot = true
	wave_break_timer.one_shot = true
	message_timer.one_shot = true
	wave_timer.wait_time = 60.0
	wave_timer.one_shot = true
	
	spawn_timer.timeout.connect(_on_spawn_timeout)
	wave_timer.timeout.connect(_on_wave_timeout)
	horde_delay_timer.timeout.connect(_on_horde_delay_timeout)
	wave_check_timer.timeout.connect(_on_wave_check_timeout)
	countdown_timer.timeout.connect(_on_countdown_timeout)
	fight_timer.timeout.connect(_on_fight_timer_timeout)
	wave_break_timer.timeout.connect(_on_wave_break_timeout)
	message_timer.timeout.connect(_on_message_timer_timeout)

func _connect_tutorial() -> void:
	var tutorial = _find_tutorial()
	if tutorial and tutorial.has_signal("tutorial_completed"):
		tutorial.tutorial_completed.connect(_on_tutorial_completed)

func _find_tutorial() -> Node:
	var tutorial = get_node_or_null("../../Control/CanvasLayer/tutorial")
	if tutorial: 
		return tutorial
	return get_tree().current_scene.find_child("tutorial", true, false)

func _on_tutorial_completed() -> void:
	tutorial_completed = true
	if not Game.paused:
		_start_countdown(3, start_wave_system)

func _start_countdown(from: int, callback: Callable) -> void:
	if Game.paused or get_tree().paused: 
		return
	countdown_step = from
	_countdown_callback = callback
	_show_countdown_step()

func _show_countdown_step() -> void:
	if Game.paused or get_tree().paused:
		return
	
	if countdown_step > 1:
		var colors = ["yellow", "orange", "red"]
		_show_message("[color=" + colors[3-countdown_step] + "][shake rate=15.0 level=5]" + str(countdown_step) + "[/shake][/color]")
		countdown_step -= 1
		countdown_timer.start()
	elif countdown_step == 1:
		_show_message("[color=red][shake rate=15.0 level=5]1[/shake][/color]")
		countdown_step = 0
		countdown_timer.start()
	else:
		_show_message("[color=green][wave amp=30.0 freq=5.0]FIGHT![/wave][/color]")
		fight_timer.start()

func _on_fight_timer_timeout() -> void:
	if Game.paused or get_tree().paused:
		return
	game_message.text = ""
	if _countdown_callback.is_valid(): 
		_countdown_callback.call()

func _on_countdown_timeout() -> void:
	if Game.paused or get_tree().paused:
		countdown_timer.start()
		return
	_show_countdown_step()

func start_wave_system() -> void:
	if waves.is_empty():
		print("No waves configured!")
		return
	_start_next_wave()

func _start_next_wave() -> void:
	current_wave_index += 1
	
	if current_wave_index >= waves.size():
		_finish_all_waves()
		return
	
	current_wave = waves[current_wave_index]
	if current_wave == null:
		print("ERROR: Wave is null!")
		_start_next_wave()
		return
	
	_initialize_wave()

func _initialize_wave() -> void:
	enemies_spawned_in_wave = 0
	hordes_spawned = 0
	is_wave_active = true
	is_spawning_horde = false
	all_enemies_spawned = false
	
	wave_count.text = str(current_wave_index + 1)
	_show_message("[color=cyan][shake rate=10.0 level=3]WAVE " + str(current_wave_index + 1) + "[/shake][/color]", 2.0)
	
	wave_timer.start()
	wave_check_timer.start()
	horde_delay_timer.wait_time = current_wave.horde_routine_delay
	horde_delay_timer.start()
	
	wave_started.emit(current_wave_index + 1)

func _finish_all_waves() -> void:
	all_waves_completed.emit()
	_show_message("[color=gold][wave amp=50.0 freq=3.0]ALL WAVES COMPLETED![/wave][/color]", 3.0)

func _start_spawning_horde() -> void:
	if not _can_spawn_horde(): 
		return
	
	is_spawning_horde = true
	hordes_spawned += 1
	spawn_timer.wait_time = current_wave.horde_spawn_interval
	spawn_timer.start()

func _can_spawn_horde() -> bool:
	if not current_wave: 
		return false
	var total_hordes = ceil(float(current_wave.enemy_count) / float(current_wave.horde_to_spawn))
	return hordes_spawned < total_hordes

func _spawn_enemy() -> void:
	if not _can_spawn(): 
		return
	
	_manage_enemy_count()
	var enemy = _create_enemy()
	if not enemy: 
		return
	
	_position_enemy(enemy)
	enemies_container.add_child(enemy)
	enemies_spawned_in_wave += 1
	
	if _is_horde_complete():
		_finish_horde()

func _can_spawn() -> bool:
	return (current_wave and player and player.get_node("HealthComponent").is_alive and
			_is_container_valid() and tutorial_completed and is_wave_active and 
			is_spawning_horde and enemies_spawned_in_wave < current_wave.enemy_count)

func _create_enemy() -> Node:
	if current_wave.horde_prefab.is_empty(): 
		return null
	var scene = current_wave.horde_prefab[randi() % current_wave.horde_prefab.size()]
	return scene.instantiate() if scene else null

func _position_enemy(enemy: Node) -> void:
	var angle = randf() * 2 * PI
	var distance = randf_range(min_spawn_distance, spawn_radius)
	enemy.position = player.position + Vector2(cos(angle) * distance, sin(angle) * distance)

func _is_horde_complete() -> bool:
	var enemies_in_horde = min(current_wave.horde_to_spawn, 
		current_wave.enemy_count - (hordes_spawned - 1) * current_wave.horde_to_spawn)
	var spawned_in_horde = enemies_spawned_in_wave - (hordes_spawned - 1) * current_wave.horde_to_spawn
	return spawned_in_horde >= enemies_in_horde

func _finish_horde() -> void:
	is_spawning_horde = false
	spawn_timer.stop()
	
	if _can_spawn_horde():
		horde_delay_timer.wait_time = current_wave.horde_routine_delay
		horde_delay_timer.start()
	else:
		all_enemies_spawned = true

func _manage_enemy_count() -> void:
	if not _is_container_valid(): 
		return
	var count = enemies_container.get_child_count()
	if count >= max_enemies_at_once:
		_kill_oldest_enemies(count - max_enemies_at_once + 1)

func _kill_oldest_enemies(amount: int) -> void:
	var enemies = enemies_container.get_children()
	for i in range(min(amount, enemies.size())):
		var enemy = enemies[i]
		if enemy and is_instance_valid(enemy):
			if enemy.has_method("on_death"): 
				enemy.on_death()
			else: 
				enemy.queue_free()

func _check_wave_completion() -> void:
	if not is_wave_active: 
		return
	
	var alive_enemies = _get_alive_enemies()
	
	if all_enemies_spawned and alive_enemies == 0:
		_complete_wave()
		return
	
	var time_left = int(ceil(wave_timer.time_left))
	if time_left <= 10:
		countdown_ui.text = "[color=red]" + str(time_left) + "[/color]"
	elif time_left <= 30:
		countdown_ui.text = "[color=orange]" + str(time_left) + "[/color]"
	else:
		countdown_ui.text = "[color=white]" + str(time_left) + "[/color]"

func _complete_wave() -> void:
	if not is_wave_active: 
		return
	
	_cleanup_wave()
	_show_message("[color=green][wave amp=40.0 freq=4.0]WAVE CLEARED![/wave][/color]", 2.0)
	wave_completed.emit(current_wave_index + 1)
	
	if current_wave_index + 1 >= waves.size():
		_finish_all_waves()
		return
	
	wave_break_timer.wait_time = wave_break_duration
	wave_break_timer.start()

func _on_wave_break_timeout() -> void:
	if not Game.paused:
		_start_countdown(3, _start_next_wave)

func _cleanup_wave() -> void:
	is_wave_active = false
	is_spawning_horde = false
	all_enemies_spawned = false
	countdown_ui.text = ""
	spawn_timer.stop()
	wave_timer.stop()
	horde_delay_timer.stop()
	wave_check_timer.stop()

func _on_spawn_timeout() -> void:
	if is_spawning_horde and _can_spawn(): 
		_spawn_enemy()

func _on_wave_timeout() -> void:
	if is_wave_active: 
		_complete_wave()

func _on_horde_delay_timeout() -> void:
	if is_wave_active and _can_spawn_horde(): 
		_start_spawning_horde()

func _on_wave_check_timeout() -> void:
	_check_wave_completion()

func _show_message(text: String, duration: float = 0.0) -> void:
	game_message.text = "[center]" + text + "[/center]"
	if duration > 0:
		message_timer.wait_time = duration
		message_timer.start()

func _on_message_timer_timeout() -> void:
	game_message.text = ""

func _get_alive_enemies() -> int:
	if not _is_container_valid(): 
		return 0
	var count = 0
	for enemy in enemies_container.get_children():
		if enemy and is_instance_valid(enemy):
			var health = enemy.get_node_or_null("HealthComponent")
			if health and health.has_method("is_alive"):
				if health.is_alive():
					count += 1
			else:
				count += 1
	return count

func _is_container_valid() -> bool:
	return enemies_container != null and is_instance_valid(enemies_container)
