extends Node2D
@onready var enemy = preload("res://Scenes/enemy_lvl_1_ranger.tscn")
func _on_timer_timeout() -> void:
	if enemy == null:
		print("Error: Enemy scene failed to preload")
		return
	
	var entity = enemy.instantiate()
	if entity == null:
		print("Error: Failed to instantiate enemy")
		return
	
	entity.position = position
	
	var enemies_node = get_tree().current_scene.get_node("enemies")
	if enemies_node:
		enemies_node.add_child(entity)
	else:
		print("enemies node is null")
