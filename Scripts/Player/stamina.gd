extends Label
@onready var line: Line2D = $"../../Sprite2D/Line2D"

func _ready() -> void:
	update()
	line.updateStamina.connect(update)

func update():
	$".".text = str("Stamina: ", int(line.current_stamina))
	if line.current_stamina <= line.max_stamina / 2:
		$".".add_theme_color_override("font_color", "red")
	else:
		$".".add_theme_color_override("font_color", "blue")
