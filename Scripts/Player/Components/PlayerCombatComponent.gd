extends Node
class_name PlayerCombatComponent

var player: CharacterBody2D
var is_attacking: bool = false

var attack_damage: float = 10.0
var self_damage: float = 10.0

func setup(player_ref: CharacterBody2D) -> void:
	player = player_ref

func update_combat(delta: float) -> void:
	update_attack_state()

func update_attack_state() -> void:
	is_attacking = Input.is_action_pressed("move_mouse")

func handle_area_collision(area: Area2D) -> void:
	if not is_enemy_area(area):
		return
		
	var attack = Attack.new()
	
	if area is HitboxComponent and area.get_parent().is_in_group("enemies"):
		var hitbox: HitboxComponent = area
		
		if is_attacking:
			attack.attack_damage = attack_damage
			hitbox.damage(attack)
			player.camera_controller.screen_shake(4, 0.1)
		else:
			attack.attack_damage = player.health_component.current_health
			player.hitbox_component.damage(attack)

func is_enemy_area(area: Area2D) -> bool:
	return area.get_parent().is_in_group("enemies")
