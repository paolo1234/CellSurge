## EnemySpawner.gd
## Spawns enemies from the edges of the camera viewport.
## Wave schedule defined in WaveManager.
class_name EnemySpawner
extends Node

@export var spawn_margin: float = 80.0   # pixels beyond viewport edge
@export var max_enemies: int = 100       # cap to prevent lag
@export var despawn_distance: float = 1200.0  # despawn if too far from player

var _camera: Camera2D
var _spawn_timer: float = 0.0
var _spawn_interval: float = 1.5         # controlled by WaveManager
var _current_wave_data: Dictionary = {}
var _hp_mult: float = 1.0
var _dmg_mult: float = 1.0

# Enemy scenes (set by WaveManager)
var enemy_scenes: Dictionary = {}


func _ready() -> void:
	_camera = get_tree().get_first_node_in_group("main_camera")


func _process(delta: float) -> void:
	_spawn_timer -= delta
	if _spawn_timer <= 0.0:
		_spawn_timer = _spawn_interval
		_spawn_batch()
	_despawn_far_enemies()


func set_wave(wave_data: Dictionary) -> void:
	_current_wave_data = wave_data
	_spawn_interval = wave_data.get("interval", 1.5)
	_hp_mult = wave_data.get("hp_mult", 1.0)
	_dmg_mult = wave_data.get("dmg_mult", 1.0)


func _spawn_batch() -> void:
	if _current_wave_data.is_empty():
		return
	var types: Array = _current_wave_data.get("types", [])
	if types.is_empty():
		return
	var count: int = _current_wave_data.get("count", 1)
	var current_count = get_tree().get_nodes_in_group("enemies").size()
	# Don't spawn if at cap
	if current_count >= max_enemies:
		return
	count = mini(count, max_enemies - current_count)
	for i in count:
		var type: String = types[randi() % types.size()]
		_spawn_enemy(type)


func _spawn_enemy(type: String) -> void:
	if not enemy_scenes.has(type):
		return
	var scene: PackedScene = enemy_scenes[type]
	var enemy := scene.instantiate()
	enemy.global_position = _get_spawn_position()
	if enemy.has_method("apply_scaling"):
		enemy.apply_scaling(_hp_mult, _dmg_mult)
	get_parent().add_child(enemy)
	EventBus.enemy_spawned.emit(type)


func _get_spawn_position() -> Vector2:
	if _camera == null:
		_camera = get_tree().get_first_node_in_group("main_camera")
		if _camera == null:
			return Vector2.ZERO

	var vp_size := get_viewport().get_visible_rect().size
	var cam_pos := _camera.global_position
	var half := vp_size * 0.5 / _camera.zoom

	var side := randi() % 4
	match side:
		0: return Vector2(cam_pos.x + randf_range(-half.x, half.x), cam_pos.y - half.y - spawn_margin)
		1: return Vector2(cam_pos.x + randf_range(-half.x, half.x), cam_pos.y + half.y + spawn_margin)
		2: return Vector2(cam_pos.x - half.x - spawn_margin, cam_pos.y + randf_range(-half.y, half.y))
		_: return Vector2(cam_pos.x + half.x + spawn_margin, cam_pos.y + randf_range(-half.y, half.y))


func _despawn_far_enemies() -> void:
	var player = get_tree().get_first_node_in_group("player")
	if player == null:
		return
	var player_pos = player.global_position
	var enemies = get_tree().get_nodes_in_group("enemies")
	for enemy in enemies:
		if enemy.global_position.distance_to(player_pos) > despawn_distance:
			enemy.queue_free()
