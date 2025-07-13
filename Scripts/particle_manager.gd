extends Node2D

class_name ParticleManager

var particle_scenes = {}

func _ready():
	register_particle("player_death", "res://Scenes/explode particle.tscn")
	register_particle("enemy", "res://Scenes/explode_enemy_death.tscn")
	register_particle("bullet", "res://Scenes/bullet_particle.tscn")

func register_particle(particle_name: String, scene_path: String):
	particle_scenes[particle_name] = scene_path

func emit_particle(particle_name: String, position: Vector2, rotation: float, duration: float = 0.0):
	if not particle_scenes.has(particle_name):
		return null
	
	var particle_scene = load(particle_scenes[particle_name])
	var particle_instance = particle_scene.instantiate()
	
	get_tree().current_scene.add_child(particle_instance)
	
	particle_instance.global_position = position
	particle_instance.global_rotation = rotation
	
	particle_instance.emitting = true
	
	var lifetime = duration
	if lifetime <= 0.0:
		if particle_instance is CPUParticles2D:
			lifetime = particle_instance.lifetime
		elif particle_instance is GPUParticles2D:
			lifetime = particle_instance.lifetime
	
	var timer = Timer.new()
	particle_instance.add_child(timer)
	timer.wait_time = lifetime
	timer.timeout.connect(_on_particle_finished.bind(particle_instance))
	timer.start()
	
	return particle_instance

func _on_particle_finished(particle_instance):
	if is_instance_valid(particle_instance):
		particle_instance.queue_free()
