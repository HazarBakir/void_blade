extends Node

signal health_changed(new_health, max_health)
signal stamina_changed(new_stamina, max_stamina)
signal level_changed(new_level)
signal experience_gained(amount)

# Base Stats
var max_health: int = 100
var max_stamina: int = 100
var base_speed: int = 600
var base_damage: int = 10

# Current Stats
var kill_count : int = 0
var is_attacking = false
var current_health: int
var current_stamina: int
var level: int = 1
var experience: int = 0
var experience_to_next_level: int = 100

# Regeneration
var health_regen: float = 5.0  # per second
var stamina_regen: float = 20.0  # per second

func _ready():
	# Initialize stats
	current_health = max_health
	current_stamina = max_stamina
	print("PlayerStats singleton initialized")

func _process(delta):
	
	# Auto regeneration every frame
	regenerate_health(delta)
	regenerate_stamina(delta)

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
func check_kill_count():
	print("Kill Count: ", kill_count)

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
	current_health = 0
	# Player explodes to particles
	# Screen Shakes at the same time
	# Everything slows down
	# after 1.5 seconds UI comes (Retry, Main Menu)

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

# Save/Load functions
func save_data() -> Dictionary:
	return {
		"current_health": current_health,
		"current_stamina": current_stamina,
		"level": level,
		"experience": experience,
		"max_health": max_health,
		"max_stamina": max_stamina,
		"base_speed": base_speed,
		"base_damage": base_damage
	}

func load_data(data: Dictionary):
	current_health = data.get("current_health", max_health)
	current_stamina = data.get("current_stamina", max_stamina)
	level = data.get("level", 1)
	experience = data.get("experience", 0)
	max_health = data.get("max_health", 100)
	max_stamina = data.get("max_stamina", 100)
	base_speed = data.get("base_speed", 600)
	base_damage = data.get("base_damage", 10)
	
	# Update UI
	health_changed.emit(current_health, max_health)
	stamina_changed.emit(current_stamina, max_stamina)
