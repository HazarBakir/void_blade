extends Control

func resume():
	get_tree().paused = false
	$AnimationPlayer.play_backwards("new_animation")
	
func pause():
	get_tree().paused = true
	$AnimationPlayer.play("new_animation")

func test_esc():
	if Input.is_action_just_pressed("escape") and get_tree().paused == false:
		pause()
	elif Input.is_action_just_pressed("escape") and get_tree().paused == true:
		resume()

func _on_resume_pressed() -> void:
	resume()

func _on_retry_pressed() -> void:
	resume()
	get_tree().reload_current_scene()

func _on_home_pressed() -> void:
	resume()
	get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")
	
func _on_quit_pressed() -> void:
	get_tree().quit()

func _process(delta: float):
	test_esc()
