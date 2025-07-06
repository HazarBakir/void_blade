extends ProgressBar
@export var health_component: HealthComponent
@onready var damage_bar: ProgressBar = $DamageBar
@onready var timer: Timer = $Timer
var tween: Tween
var prev_health: float

func _ready() -> void:
	health_component.updateHealth.connect(update)
	prev_health = health_component.current_health

func get_health_percentage() -> float:
	return health_component.current_health * 100 / health_component.MAX_HEALTH

func update():
	var target_value = get_health_percentage()
	var duration = 2 if target_value <= 0 else 0.5
	
	if tween:
		tween.kill()
	
	tween = create_tween()
	tween.tween_property(self, "value", target_value, duration)
	
	if target_value < prev_health:
		timer.start()
	else:
		tween.tween_property(damage_bar, "value", target_value, duration+0.3)
	
	prev_health = health_component.current_health

func _on_timer_timeout() -> void:
	var target_value = get_health_percentage()
	var duration = 2 if target_value <= 0 else 0.5
	
	var damage_tween = create_tween()
	damage_tween.tween_property(damage_bar, "value", target_value, duration+0.3)
