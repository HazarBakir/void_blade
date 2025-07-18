extends Area2D
class_name HitboxComponent

@export var health_component: HealthComponent
@export var owner_name: String


func damage(attack: Attack):
	print(owner)
	if health_component:
		health_component.damage(attack)
