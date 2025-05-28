extends Node

var crosshair_texture_path = "res://Sprites/crosshair054.png"
var crosshair_scale = 0.6  # Desired size (1.0 = original size)

var crosshair: Sprite2D

func _ready():
	# Hide mouse cursor
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	
	# Create crosshair
	create_crosshair()

func _process(_delta):
	# Move crosshair to mouse position
	if crosshair:
		var mouse_pos = get_viewport().get_mouse_position()
		crosshair.global_position = mouse_pos
		crosshair.z_index = 1000  # Make sure it's on top

func create_crosshair():
	# Create crosshair sprite
	crosshair = Sprite2D.new()
	crosshair.name = "Crosshair"
	
	# Load existing crosshair texture
	var texture = load(crosshair_texture_path)
	if texture:
		print("Texture loaded successfully!")
		crosshair.texture = texture
	else:
		print("Crosshair texture not found: " + crosshair_texture_path)
		return
	
	# Scale down
	crosshair.scale = Vector2(crosshair_scale, crosshair_scale)
	
	# Add directly to current scene tree
	get_tree().current_scene.add_child(crosshair)
	print("Crosshair added to scene")

# Change crosshair scale
func set_crosshair_scale(new_scale: float):
	crosshair_scale = new_scale
	if crosshair:
		crosshair.scale = Vector2(crosshair_scale, crosshair_scale)

# Show/hide crosshair
func set_crosshair_visible(visible: bool):
	if crosshair:
		crosshair.visible = visible
