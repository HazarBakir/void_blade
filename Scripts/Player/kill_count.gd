extends Label
@onready var player: CharacterBody2D = get_tree().get_first_node_in_group("player")


func _process(_delta: float) -> void:
	$".".text = str("Kill Counter: ", player.kill_count)
