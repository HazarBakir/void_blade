extends Node
class_name PlayerCameraController

var player: CharacterBody2D
var camera: Camera2D

var normal_zoom: Vector2 = Vector2(1.0, 1.0)
var attack_zoom: Vector2 = Vector2(1.4, 1.4)
var zoom_speed: float = 3.0
const SCREEN_WIDTH: float = 1920.0
const SCREEN_HEIGHT: float = 1080.0
const CAMERA_OFFSET_FACTOR: float = 180.0
const CAMERA_LERP_SPEED: float = 4.5

func setup(player_ref: CharacterBody2D, camera_ref: Camera2D) -> void:
	player = player_ref
	camera = camera_ref
	camera.zoom = normal_zoom

func update_camera(delta: float) -> void:
	update_camera_offset(delta)
	update_zoom(delta)

func update_camera_offset(delta: float) -> void:
	var mouse_position = player.movement_component.get_mouse_position()
	var target_offset_x = (mouse_position.x - player.global_position.x) / (SCREEN_WIDTH / 2.6) * CAMERA_OFFSET_FACTOR
	var target_offset_y = (mouse_position.y - player.global_position.y) / (SCREEN_HEIGHT / 2.6) * CAMERA_OFFSET_FACTOR
	camera.offset.x = lerp(camera.offset.x, target_offset_x, CAMERA_LERP_SPEED * delta)
	camera.offset.y = lerp(camera.offset.y, target_offset_y, CAMERA_LERP_SPEED * delta)

func update_zoom(delta: float) -> void:
	var target_zoom = attack_zoom if player.get_is_attacking() else normal_zoom
	camera.zoom.x = lerp(camera.zoom.x, target_zoom.x, zoom_speed * delta)
	camera.zoom.y = lerp(camera.zoom.y, target_zoom.y, zoom_speed * delta)

func screen_shake(intensity: float, duration: float) -> void:
	if camera.has_method("screen_shake"):
		camera.screen_shake(intensity, duration)
