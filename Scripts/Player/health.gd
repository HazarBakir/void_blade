extends Label
@onready var health_component: HealthComponent = %player.get_node("%HealthComponent")

func _process(_delta: float) -> void:
	if not health_component == null and health_component.current_health > 0:
		$".".text = str("Health: ", int(health_component.current_health))
	else:
		$".".text = str("Health: ", 0)
