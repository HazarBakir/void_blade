extends Control
@onready var resume_button: Button = $PanelContainer/VBoxContainer/Resume
@onready var retry_button: Button = $PanelContainer/VBoxContainer/Retry
@onready var home_button: Button = $PanelContainer/VBoxContainer/Home
@onready var quit_button: Button = $PanelContainer/VBoxContainer/Quit
@onready var player: CharacterBody2D = get_tree().get_first_node_in_group("player")
@onready var death_timer: Timer = Timer.new()
var player_was_dead = false

func _ready() -> void:
	visible = false
	add_child(death_timer)
	death_timer.wait_time = 0.8
	death_timer.one_shot = true
	death_timer.timeout.connect(_on_death_timer_timeout)
	
func resume():
	get_tree().paused = false
	Game.paused = false
	disable_buttons()
	$AnimationPlayer.play_backwards("new_animation")
	visible = false
	
func pause():
	get_tree().paused = true
	Game.paused = true
	enable_buttons()
	visible = true
	$AnimationPlayer.play("new_animation")

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

func test_esc():
	if not player or not is_instance_valid(player):
		return
		
	if Input.is_action_just_pressed("escape") and get_tree().paused == false and player.health_component.is_alive:
		pause()
	elif Input.is_action_just_pressed("escape") and get_tree().paused == true and player.health_component.is_alive:
		resume()
	
	if player.health_component.is_alive == false and player_was_dead == false:
		player_was_dead = true
		death_timer.start()
	elif player.health_component.is_alive == true:
		player_was_dead = false
		death_timer.stop()

func _on_death_timer_timeout():
	pause()

func _on_resume_pressed() -> void:
	resume()

func _on_retry_pressed() -> void:
	player_was_dead = false
	death_timer.stop()
	resume()
	get_tree().reload_current_scene()

func _on_home_pressed() -> void:
	player_was_dead = false
	death_timer.stop()
	resume()
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
	
func _on_quit_pressed() -> void:
	get_tree().quit()

func _process(delta: float):
	test_esc()

func disable_buttons():
	resume_button.disabled = true
	retry_button.disabled = true
	home_button.disabled = true
	quit_button.disabled = true
	
func enable_buttons():
	if not player or not is_instance_valid(player):
		return
		
	if player.health_component.is_alive == false:
		resume_button.disabled = true
		resume_button.visible = false
	else:
		resume_button.disabled = false
		resume_button.visible = true
	
	retry_button.disabled = false
	quit_button.disabled = false
	home_button.disabled = false
