extends Area2D

var damage = 20.0

func _on_area_entered(area: Area2D) -> void:
	var attack = Attack.new()
	if area is HitboxComponent:
		var hitbox: HitboxComponent = area
		attack.attack_damage = damage * 1000
		hitbox.damage(attack)
