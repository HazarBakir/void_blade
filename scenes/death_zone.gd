extends Area2D

var damage = 20.0
@onready var enemies_container: Node = get_tree().current_scene.get_node("enemies")
@onready var player: CharacterBody2D = get_tree().get_first_node_in_group("player")

func _on_area_entered(area: Area2D) -> void:
	var attack = Attack.new()
	if area is HitboxComponent:
		var hitbox: HitboxComponent = area
		attack.attack_damage = damage * 1000
		hitbox.damage(attack)
