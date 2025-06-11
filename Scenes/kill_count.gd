extends Label

func _process(_delta: float) -> void:
	$".".text = str("Kill Counter: ", PlayerStats.kill_count)
