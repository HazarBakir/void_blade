extends Node2D

class_name ParticleManager

# Particle scene'lerinin local path'lerini sakla
var particle_scenes = {}

func _ready():
	# Particle'ları kaydet
	register_particle("player_death", "res://Scenes/explode particle.tscn")
	register_particle("enemy", "res://Scenes/explode_enemy_death.tscn")
	register_particle("bullet", "res://Scenes/bullet_particle.tscn")

# Particle scene'ini kaydet
func register_particle(particle_name: String, scene_path: String):
	particle_scenes[particle_name] = scene_path

# Particle emit et
func emit_particle(particle_name: String, position: Vector2, duration: float = 0.0):
	if not particle_scenes.has(particle_name):
		print("Hata: Particle bulunamadı: ", particle_name)
		return null
	
	# Scene'i yükle ve instantiate et
	var particle_scene = load(particle_scenes[particle_name])
	var particle_instance = particle_scene.instantiate()
	
	# Sahneye ekle
	get_tree().current_scene.add_child(particle_instance)
	
	# Pozisyonu ayarla
	particle_instance.global_position = position
	
	# Particle'ı başlat
	particle_instance.emitting = true
	
	# Lifetime kontrolü
	var lifetime = duration
	if lifetime <= 0.0:
		# Particle'ın kendi lifetime'ını kullan
		if particle_instance is CPUParticles2D:
			lifetime = particle_instance.lifetime
		elif particle_instance is GPUParticles2D:
			lifetime = particle_instance.lifetime
	
	# Belirtilen süre sonra particle'ı temizle
	var timer = Timer.new()
	particle_instance.add_child(timer)
	timer.wait_time = lifetime
	timer.timeout.connect(_on_particle_finished.bind(particle_instance))
	timer.start()
	
	return particle_instance

# Particle bittiğinde çağrılacak fonksiyon
func _on_particle_finished(particle_instance):
	if is_instance_valid(particle_instance):
		particle_instance.queue_free()
