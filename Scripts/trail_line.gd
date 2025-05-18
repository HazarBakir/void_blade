extends Line2D

var previous_position: Vector2

func _ready() -> void:
	await get_parent().ready
	previous_position = get_parent().global_position
	
func _process(_delta: float) -> void:
	var current_position = get_parent().global_position
	
	if current_position != previous_position:
		add_point(current_position)
		
		if points.size() > 30:
			remove_point(0)
			
		previous_position = current_position
