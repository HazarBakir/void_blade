extends Area2D

var speed = 500.0
var target: CharacterBody2D
var direction = Vector2.ZERO
var follow_target = true

func _ready():
	var follow_timer = Timer.new()
	follow_timer.wait_time = 1.0
	follow_timer.one_shot = true
	follow_timer.timeout.connect(_stop_following)
	add_child(follow_timer)
	follow_timer.start()
	scale = Vector2(1.3, 1.3)

func _physics_process(delta):
	move_to_player()
	position += direction * speed * delta

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("player") or area.get_parent().is_in_group("player") and area.name == "BulletDetectArea":
		if PlayerStats.is_attacking == false:
			PlayerStats.take_damage(10)
		queue_free()


func _stop_following():
	follow_target = false
	
	var destroy_timer = Timer.new()
	destroy_timer.wait_time = 2.0
	destroy_timer.one_shot = true
	destroy_timer.timeout.connect(_destroy_projectile)
	add_child(destroy_timer)
	destroy_timer.start()

func _destroy_projectile():
	queue_free()

func move_to_player():
	if follow_target and target:
		direction = (target.position - position).normalized()
		look_at(target.position)
