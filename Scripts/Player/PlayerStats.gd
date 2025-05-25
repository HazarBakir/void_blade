class_name PlayerStats
extends Resource

signal health_changed(new_health, max_health)
signal stamina_changed(new_stamina, max_stamina)
signal level_changed(new_level)
signal experience_gained(amount)

# Base Stats
@export var max_health: int = 100
@export var max_stamina: int = 100
@export var base_speed: int = 600
@export var base_damage: int = 10

# Current Stats
var current_health: int
var current_stamina: int
var level: int = 1
var experience: int = 0
var experience_to_next_level: int = 100

# Regeneration
var health_regen: float = 5.0  # per second
var stamina_regen: float = 20.0  # per second

func _init():
	current_health = max_health
	current_stamina = max_stamina

# Health Management
func take_damage(amount: int):
	current_health = max(0, current_health - amount)
	health_changed.emit(current_health, max_health)
	if current_health <= 0:
		die()

func heal(amount: int):
	current_health = min(max_health, current_health + amount)
	health_changed.emit(current_health, max_health)

func regenerate_health(delta: float):
	if current_health < max_health:
		heal(int(health_regen * delta))

# Stamina Management
func use_stamina(amount: int) -> bool:
	if current_stamina >= amount:
		current_stamina -= amount
		stamina_changed.emit(current_stamina, max_stamina)
		return true
	return false

func regenerate_stamina(delta: float):
	if current_stamina < max_stamina:
		current_stamina = min(max_stamina, current_stamina + int(stamina_regen * delta))
		stamina_changed.emit(current_stamina, max_stamina)

# Level & Experience
func gain_experience(amount: int):
	experience += amount
	experience_gained.emit(amount)
	check_level_up()

func check_level_up():
	while experience >= experience_to_next_level:
		level_up()

func level_up():
	level += 1
	experience -= experience_to_next_level
	experience_to_next_level = int(experience_to_next_level * 1.5)  # Exponential scaling
	
	# Stat increases per level
	max_health += 20
	max_stamina += 10
	base_damage += 2
	
	# Restore health/stamina on level up
	current_health = max_health
	current_stamina = max_stamina
	
	level_changed.emit(level)
	health_changed.emit(current_health, max_health)
	stamina_changed.emit(current_stamina, max_stamina)

func die():
	print("Player died!")
	# Handle death logic here

# Getters for computed stats
func get_current_speed() -> int:
	# Could add modifiers here (items, buffs, etc.)
	return base_speed

func get_current_damage() -> int:
	# Could add modifiers here
	return base_damage

# Utility functions
func is_alive() -> bool:
	return current_health > 0

func is_at_full_health() -> bool:
	return current_health >= max_health

func is_at_full_stamina() -> bool:
	return current_stamina >= max_stamina

func get_health_percentage() -> float:
	return float(current_health) / float(max_health)

func get_stamina_percentage() -> float:
	return float(current_stamina) / float(max_stamina)
