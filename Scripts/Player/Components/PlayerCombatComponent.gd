extends Node
class_name PlayerCombatComponent

var player: CharacterBody2D
var is_attacking: bool = false
var attack_damage: float = 10.0
var was_mouse_pressed: bool = false
var can_start_attack: bool = true
@onready var line = get_node_or_null("../Sprite2D/Line2D")

func setup(player_ref: CharacterBody2D) -> void:
	player = player_ref

func update_combat(delta: float) -> void:
	update_attack_state()

func update_attack_state() -> void:
	var mouse_pressed = Input.is_action_pressed("move_mouse")
	
	handle_mouse_input_change(mouse_pressed)
	handle_stamina_depletion(mouse_pressed)
	handle_attack_logic(mouse_pressed)
	
	was_mouse_pressed = mouse_pressed

func handle_mouse_input_change(mouse_pressed: bool) -> void:
	if not was_mouse_pressed and mouse_pressed:
		can_start_attack = true

func handle_stamina_depletion(mouse_pressed: bool) -> void:
	if not can_attack():
		is_attacking = false
		if mouse_pressed:
			can_start_attack = false

func handle_attack_logic(mouse_pressed: bool) -> void:
	if can_attack():
		if mouse_pressed and can_start_attack:
			is_attacking = true
		elif not mouse_pressed:
			is_attacking = false
			can_start_attack = true

func can_attack() -> bool:
	return line.current_stamina > line.min_stamina + 0.1

func handle_area_collision(area: Area2D) -> void:
	if not is_enemy_area(area):
		return
		
	var attack = Attack.new()
	
	if area is HitboxComponent and is_enemy_area(area):
		var hitbox: HitboxComponent = area
		if is_attacking and can_attack():
			attack.attack_damage = attack_damage
			hitbox.damage(attack)
			player.camera_controller.screen_shake(4, 0.1)
		else:
			attack.attack_damage = player.health_component.current_health
			player.hitbox_component.damage(attack)

func is_enemy_area(area: Area2D) -> bool:
	return area.get_parent().is_in_group("enemies")
