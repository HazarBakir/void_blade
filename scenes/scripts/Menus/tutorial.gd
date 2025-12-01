extends Control
class_name Tutorial
@onready var tutorial_animation_player: AnimationPlayer = $AnimationPlayer
@onready var canvas_layer: CanvasLayer = $CanvasLayer
signal tutorial_completed
var tutorial_passed : bool = false
var escape_pressed : bool = false

func _ready() -> void:
	tutorial_animation_player.play("tutorial")
	add_to_group("tutorial")

func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("escape"):
		if escape_pressed == false:
			escape_pressed = true
			canvas_layer.layer = 1
		else:
			escape_pressed = false
			canvas_layer.layer = 5

func _process(delta: float) -> void:
	if tutorial_passed == false and Game.paused == false:
		if Input.is_action_pressed("move_mouse"):
			complete_tutorial()

func complete_tutorial():
	if tutorial_passed == false:
		tutorial_animation_player.play_backwards("tutorial")
		tutorial_passed = true
		canvas_layer.layer = -1
		tutorial_completed.emit()

func is_tutorial_passed() -> bool:
	return tutorial_passed
