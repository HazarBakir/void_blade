extends Label

func _process(_delta: float) -> void:
	$".".text = str(PlayerStats.current_health)
