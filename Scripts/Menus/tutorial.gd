extends Control
class_name Tutorial
@onready var tutorial_animation_player: AnimationPlayer = $tutorial_animation_player

signal tutorial_completed

var tutorial_passed : bool = false
@export var time_scale = 1.0

const SAVE_FILE_PATH = "user://tutorial_completed.save"

func _ready() -> void:
	
	if is_tutorial_already_completed():
		tutorial_passed = true
		tutorial_completed.emit()
		return
	
	tutorial_animation_player.play("tutorial")
	
	add_to_group("tutorial")

func _process(delta: float) -> void:
	Engine.time_scale = time_scale
	if tutorial_passed == false and Input.is_action_pressed("move_mouse"):
		tutorial_animation_player.play_backwards("tutorial")
		tutorial_passed = true
		
		save_tutorial_completion()
		
		tutorial_completed.emit()

func is_tutorial_passed() -> bool:
	return tutorial_passed

func is_tutorial_already_completed() -> bool:
	if FileAccess.file_exists(SAVE_FILE_PATH):
		var file = FileAccess.open(SAVE_FILE_PATH, FileAccess.READ)
		if file:
			var completed = file.get_var()
			file.close()
			return completed
	return false

func save_tutorial_completion() -> void:
	var file = FileAccess.open(SAVE_FILE_PATH, FileAccess.WRITE)
	if file:
		file.store_var(true)
		file.close()

func reset_tutorial_completion() -> void:
	if FileAccess.file_exists(SAVE_FILE_PATH):
		DirAccess.remove_absolute(SAVE_FILE_PATH)
