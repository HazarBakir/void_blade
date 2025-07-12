extends Node2D
class_name HealthComponent
signal updateHealth

@export var MAX_HEALTH: float = 100.0
var current_health: float
var is_alive: bool

func _ready() -> void:
	current_health = MAX_HEALTH
	is_alive = true

func damage(attack: Attack):
	current_health -= attack.attack_damage
	updateHealth.emit()
	if current_health <= 0:
		is_alive = false
