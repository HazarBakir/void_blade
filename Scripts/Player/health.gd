extends ProgressBar
@onready var health_component: HealthComponent = %player.get_node("%HealthComponent")
var tween: Tween

func _ready() -> void:
	health_component.updateHealth.connect(update)
	
func update():
	var target_value = health_component.current_health * 100 / health_component.MAX_HEALTH
	var duration = 0.5
	if target_value <= 0:
		duration = 2.5
	tween = create_tween()
	tween.tween_property(self, "value", target_value, duration)
