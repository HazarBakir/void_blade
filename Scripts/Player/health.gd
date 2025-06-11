extends Label

func _process(_delta: float) -> void:
	$".".text = str("Health: ", PlayerStats.current_health)
