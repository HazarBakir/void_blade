extends Area2D

var speed = 300
var target: CharacterBody2D
var direction = Vector2.ZERO
var follow_target = true  # Start by following the target

func _physics_process(delta):
	if follow_target and target:
		direction = (target.position - position).normalized()
	
	position += direction * speed * delta
	look_at(position + direction)

func _on_body_entered(body):
	if body.is_in_group("player"):
		queue_free()

func _on_timer_timeout() -> void:
	follow_target = false  # Stop following, keep last direction
