extends Line2D

signal updateStamina


var previous_position: Vector2
var fade_timer: float = 0.0
var is_fading: bool = false
var fade_speed: float = 2.0
var points_alpha: Array = []

var max_stamina: float = 25.0
var min_stamina: float = 0.0
var current_stamina: float = 25.0
var attack_cost: float = 5
var stamina_refill: float = 3.5

@onready var player_combat = get_node_or_null("../../PlayerCombatComponent")

func _ready():
	await get_parent().ready
	previous_position = get_parent().global_position
	set_as_top_level(true)

func _process(delta: float):
	print(current_stamina)
	if player_combat and player_combat.is_attacking and current_stamina > min_stamina:
		if current_stamina <= min_stamina + 0.1:
			player_combat.is_attacking = false
		current_stamina = max(min_stamina, current_stamina - attack_cost * delta * 2.5)
		updateStamina.emit()
	elif player_combat and not player_combat.is_attacking and current_stamina < max_stamina:
		current_stamina = min(max_stamina, current_stamina + stamina_refill * delta * 2.5)
		updateStamina.emit()



	var current_position = get_parent().global_position
	if current_position != previous_position:
		is_fading = false
		fade_timer = 0.0

		add_point(current_position)
		points_alpha.append(1.0)
		previous_position = current_position
	else:
		is_fading = true

	var max_points = current_stamina
	while points.size() > max_points and points.size() > 1:
			remove_point(0)
			points_alpha.remove_at(0)


	if is_fading:
		fade_timer += delta
		apply_fade(delta)

func apply_fade(delta: float):
	if points_alpha.is_empty():
		return

	for i in range(points_alpha.size()):
		var fade_factor = float(i) / float(points_alpha.size())
		points_alpha[i] = max(0.0, points_alpha[i] - fade_speed * delta * (1.0 - fade_factor * 0.5))

	var new_gradient = Gradient.new()
	for i in range(points_alpha.size()):
		var point_color = default_color
		point_color.a = points_alpha[i]
		new_gradient.add_point(float(i) / max(1, points_alpha.size() - 1), point_color)

	self.gradient = new_gradient

	if points_alpha.size() > 0 and points_alpha[0] <= 0.01 and points.size() > 0:
		remove_point(0)
		points_alpha.remove_at(0)
