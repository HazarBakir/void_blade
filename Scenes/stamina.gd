extends Label
@onready var line: Line2D = $"../../Sprite2D/Line2D"


func _ready() -> void:
	update()
	line.updateStamina.connect(update)

func update():
	$".".text = str("Stamina: ", int(line.current_stamina))
