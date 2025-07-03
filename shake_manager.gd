extends Node
class_name ShakeManager

var shake_intensity: float = 0.0
var active_shake_time: float = 0.0
var shake_decay: float = 5.0
var shake_time: float = 0.0
var shake_time_speed: float = 20.0
var noise = FastNoiseLite.new()

var target_object: Node
var original_position: Vector2
var original_offset: Vector2
var is_camera: bool = false
var is_control: bool = false

func _ready():
	set_physics_process(false)

func _physics_process(delta: float) -> void:
	if not target_object:
		return
		
	if active_shake_time > 0:
		shake_time += delta * shake_time_speed
		active_shake_time -= delta
		
		var shake_offset = Vector2(
			noise.get_noise_2d(shake_time, 0) * shake_intensity,
			noise.get_noise_2d(0, shake_time) * shake_intensity
		)
		
		# Apply shake based on object type
		if is_camera:
			target_object.offset = original_offset + shake_offset
		elif is_control:
			target_object.position = original_position + shake_offset
		else:
			target_object.position = original_position + shake_offset
		
		shake_intensity = max(shake_intensity - shake_decay * delta, 0)
	else:
		# Smoothly return to original position/offset
		if is_camera:
			target_object.offset = lerp(target_object.offset, original_offset, 10.5 * delta)
			if target_object.offset.distance_to(original_offset) < 0.1:
				target_object.offset = original_offset
				_stop_shake()
		elif is_control:
			target_object.position = lerp(target_object.position, original_position, 10.5 * delta)
			if target_object.position.distance_to(original_position) < 0.1:
				target_object.position = original_position
				_stop_shake()
		else:
			target_object.position = lerp(target_object.position, original_position, 10.5 * delta)
			if target_object.position.distance_to(original_position) < 0.1:
				target_object.position = original_position
				_stop_shake()

func shake_object(object: Node, intensity: float, time: float, decay: float = 5.0, speed: float = 20.0):
	"""
	Shake any Node2D object (Camera2D, Sprite2D, CharacterBody2D, etc.) or Control node (ProgressBar, Label, etc.)
	
	Args:
		object: The Node2D or Control object to shake
		intensity: How strong the shake should be
		time: How long the shake should last
		decay: How fast the shake intensity decreases
		speed: How fast the shake oscillates
	"""
	target_object = object
	
	# Check object type and store original values accordingly
	is_camera = object is Camera2D
	is_control = object is Control
	
	if is_camera:
		original_offset = object.offset
	elif is_control or object is Node2D:
		original_position = object.position
	else:
		push_error("ShakeManager: Object must be Node2D or Control")
		return
	
	# Configure shake parameters
	randomize()
	noise.seed = randi()
	noise.frequency = 2.0
	
	shake_intensity = intensity
	active_shake_time = time
	shake_time = 0.0
	shake_decay = decay
	shake_time_speed = speed
	
	set_physics_process(true)

func _stop_shake():
	set_physics_process(false)
	target_object = null
	shake_intensity = 0.0
	active_shake_time = 0.0

func is_shaking() -> bool:
	return active_shake_time > 0
