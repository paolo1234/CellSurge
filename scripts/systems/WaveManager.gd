## WaveManager.gd
## Manages wave escalation over the 20-minute run.
class_name WaveManager
extends Node

@onready var spawner: Node = $"../EnemySpawner"

const WAVES := [
	# [start_minute, wave_data]
	[0,  {"types": ["batterio"], "count": 2, "interval": 2.0, "hp_mult": 1.0, "dmg_mult": 1.0}],
	[2,  {"types": ["batterio", "virus"], "count": 3, "interval": 1.8, "hp_mult": 1.2, "dmg_mult": 1.1}],
	[4,  {"types": ["batterio", "virus", "fungo"], "count": 4, "interval": 1.5, "hp_mult": 1.5, "dmg_mult": 1.2}],
	[8,  {"types": ["batterio", "virus", "fungo"], "count": 6, "interval": 1.2, "hp_mult": 2.0, "dmg_mult": 1.4}],
	[10, {"types": ["batterio", "virus", "fungo"], "count": 5, "interval": 1.0, "hp_mult": 2.5, "dmg_mult": 1.6}],
	[14, {"types": ["batterio", "virus", "fungo"], "count": 7, "interval": 0.9, "hp_mult": 3.0, "dmg_mult": 1.8}],
	[17, {"types": ["batterio", "virus", "fungo"], "count": 8, "interval": 0.8, "hp_mult": 4.0, "dmg_mult": 2.0}],
]

var _last_applied_wave: int = -1
var _current_hp_mult: float = 1.0
var _current_dmg_mult: float = 1.0


func _ready() -> void:
	set_process(true)


func _process(_delta: float) -> void:
	if not GameManager.run_active:
		return
	var current_minute := int(GameManager.run_time / 60.0)
	_check_wave_change(current_minute)
	_check_boss_trigger(GameManager.run_time)


func _check_wave_change(current_minute: int) -> void:
	for i in range(WAVES.size() - 1, -1, -1):
		var wave_minute: int = WAVES[i][0]
		if current_minute >= wave_minute and _last_applied_wave < i:
			_last_applied_wave = i
			var wave_data = WAVES[i][1]
			_current_hp_mult = wave_data.get("hp_mult", 1.0)
			_current_dmg_mult = wave_data.get("dmg_mult", 1.0)
			spawner.set_wave(wave_data)
			EventBus.wave_changed.emit(current_minute)
			break


func _check_boss_trigger(run_time: float) -> void:
	# Boss at exactly 10 minutes
	if run_time >= 600.0 and run_time < 602.0 and _last_applied_wave < 99:
		_spawn_boss("super_cellula")
		_last_applied_wave = 99
	# Boss final at 20 minutes
	if run_time >= 1200.0 and _last_applied_wave < 100:
		_spawn_boss("prione")
		_last_applied_wave = 100


func _spawn_boss(boss_id: String) -> void:
	EventBus.boss_spawned.emit(boss_id)
	# Boss scene is instantiated directly
	var boss_path := "res://scenes/gameplay/enemies/Boss_%s.tscn" % boss_id
	if not ResourceLoader.exists(boss_path):
		return
	var scene: PackedScene = load(boss_path)
	var boss := scene.instantiate()
	boss.global_position = get_tree().get_first_node_in_group("player").global_position + Vector2(0, -400)
	get_parent().add_child(boss)
