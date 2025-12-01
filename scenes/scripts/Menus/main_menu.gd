extends Control


func _on_play_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/game_scene.tscn")

func _on_options_pressed() -> void:
	pass


func _on_quit_pressed() -> void:
	get_tree().quit()
