extends CharacterBody2D

const bullet = preload("res://scenes/bullet.tscn")
@onready var target: CharacterBody2D = %player
@onready var game_scene = get_node("/root/game_scene")

var speed = 150

func _physics_process(delta):
	move_to_player()
	look_at(target.position)
	move_and_slide()
	
func shoot():
	var b = bullet.instantiate()
	b.global_transform = $"Muzzle-Shoot_Point".global_transform
	b.target = target
	game_scene.add_child(b)

func _on_timer_timeout() -> void:
	shoot()

func move_to_player():
	var direction = (target.position - position).normalized()
	velocity = direction * speed
