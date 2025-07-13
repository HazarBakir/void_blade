extends CharacterBody2D

@onready var health_component: HealthComponent = $HealthComponent
@onready var hitbox_component: HitboxComponent = $HitboxComponent
@onready var movement_component: PlayerMovementComponent = $PlayerMovementComponent
@onready var camera_controller: PlayerCameraController = $PlayerCameraController
@onready var combat_component: PlayerCombatComponent = $PlayerCombatComponent
@onready var camera: Camera2D = $Camera2D
@onready var sprite: AnimatedSprite2D = $Sprite2D

var kill_count: int = 0

func _ready() -> void:
	add_to_group("player")
	setup_components()

func _physics_process(delta: float) -> void:
	if health_component.is_alive:
		handle_living_player(delta)
	else:
		trigger_death()

func setup_components() -> void:
	movement_component.setup(self)
	camera_controller.setup(self, camera)
	combat_component.setup(self)
	

func handle_living_player(delta: float) -> void:
	movement_component.handle_movement(delta)
	camera_controller.update_camera(delta)
	combat_component.update_combat(delta)

func trigger_death() -> void:
	if sprite != null:
		camera_controller.screen_shake(25, 3)
		particle_manager.emit_particle("player_death", global_position, global_rotation)
		sprite.queue_free()

func _on_area_entered(area: Area2D) -> void:
	combat_component.handle_area_collision(area)

func get_is_attacking() -> bool:
	return combat_component.is_attacking

func increment_kill_count() -> void:
	kill_count += 1
