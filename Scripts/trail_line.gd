extends Line2D

var previous_position: Vector2 = Vector2.ZERO
var orb_radius: float = 0.0

func _ready() -> void:
	await get_parent().ready
	
	if get_parent().has_method("get_texture") or get_parent().get("texture") != null:
		var texture = get_parent().texture
		orb_radius = texture.get_size().x / 5.0  
	elif get_parent() is Sprite2D or get_parent() is AnimatedSprite2D:
		var texture_size = get_parent().texture.get_size() if get_parent() is Sprite2D else get_parent().sprite_frames.get_frame_texture(get_parent().animation, 0).get_size()
		orb_radius = texture_size.x / 5.0
	else:
		orb_radius = 10.0
		
	previous_position = get_parent().global_position
	
func _process(delta: float) -> void:
	var current_position = get_parent().global_position
	
	if current_position != previous_position:
		var direction = (current_position - previous_position).normalized()
		
		if direction != Vector2.ZERO:
			add_point(current_position - orb_radius * direction)
		else:
			add_point(current_position)
			
		if points.size() > 30:
			remove_point(0)
			
		previous_position = current_position
