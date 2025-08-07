extends Resource
class_name ScriptableWave

@export_group("Wave Settings")
@export var wave_duration: float = 60.0
@export var enemy_count: int = 10

@export_group("Enemy Configuration") 
@export var horde_prefab: Array[PackedScene] = []

@export_group("Spawn Timing")
@export var horde_routine_delay: float = 1.0
@export var horde_spawn_interval: float = 0.3
@export var horde_to_spawn: int = 10

@export_group("Special Waves")
@export var boon_wave: bool = false
@export var boss_wave: bool = false
