extends CharacterBody2D
const bullet = preload("res://scenes/bullet.tscn")
@onready var target: CharacterBody2D = %player
@onready var game_scene = get_node("/root/game_scene")
var speed = 250.0
var original_speed = 250.0
var accel = 8.0
var decel = 5.0 
var current_speed = 0.0

func _ready() -> void:
	add_to_group("enemies")
	
func _physics_process(delta):
	move_to_player(delta)
	look_at(target.position)
	move_and_slide()
	
func shoot():
	var b = bullet.instantiate()
	b.global_transform = $"Muzzle-Shoot_Point".global_transform
	b.target = target
	game_scene.add_child(b)
	
func _on_timer_timeout() -> void:
	shoot()
	
func move_to_player(delta):
	var direction = (target.position - position).normalized()
	if speed == 0:
		current_speed = lerp(current_speed, 0.0, decel * delta)
	else:
		current_speed = lerp(current_speed, speed, accel * delta)
	
	var target_velocity = direction * current_speed
	velocity = target_velocity
