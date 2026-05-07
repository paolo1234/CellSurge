## WaveManager.gd
## Manages wave escalation over the 20-minute run with announcements and boss spawns.
class_name WaveManager
extends Node

@onready var spawner: Node = $"../EnemySpawner"

const WAVES := [
	[0,  {"types": ["batterio"], "count": 3, "interval": 2.0, "hp_mult": 1.0, "dmg_mult": 1.0, "name": "INIZIO"}],
	[2,  {"types": ["batterio", "virus"], "count": 5, "interval": 1.8, "hp_mult": 1.3, "dmg_mult": 1.2, "name": "VIRUS INCOMING"}],
	[4,  {"types": ["batterio", "virus", "fungo", "ranged_cell"], "count": 6, "interval": 1.5, "hp_mult": 1.6, "dmg_mult": 1.3, "name": "FUNGHI!"}],
	[6,  {"types": ["batterio", "virus", "fungo", "ranged_cell"], "count": 8, "interval": 1.3, "hp_mult": 2.0, "dmg_mult": 1.5, "name": "INTENSIFICAZIONE"}],
	[8,  {"types": ["batterio", "virus", "fungo", "ranged_cell"], "count": 10, "interval": 1.0, "hp_mult": 2.5, "dmg_mult": 1.7, "name": "⚠ BOSS: SUPER CELLULA"}],
	[10, {"types": ["batterio", "virus", "fungo", "ranged_cell", "leech"], "count": 12, "interval": 0.9, "hp_mult": 3.0, "dmg_mult": 2.0, "name": "INFERNO"}],
	[14, {"types": ["batterio", "virus", "fungo", "ranged_cell", "leech"], "count": 15, "interval": 0.7, "hp_mult": 4.0, "dmg_mult": 2.5, "name": "LATE GAME"}],
	[17, {"types": ["batterio", "virus", "fungo", "ranged_cell", "leech", "splitter"], "count": 20, "interval": 0.5, "hp_mult": 5.0, "dmg_mult": 3.0, "name": "⚠ ENDGAME RUSH"}],
]

var _last_applied_wave: int = -1
var _boss_10_spawned: bool = false
var _boss_20_spawned: bool = false

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
			spawner.set_wave(wave_data)
			EventBus.wave_changed.emit(current_minute)
			# Announce wave
			var wave_name: String = wave_data.get("name", "")
			if wave_name != "":
				var color := Color(1, 0.67, 0.1)  # Gold
				if "BOSS" in wave_name or "⚠" in wave_name:
					color = Color(1, 0.2, 0.1)  # Red for danger
				EventBus.wave_announcement.emit("⚡ %s ⚡" % wave_name, color)
			break

func _check_boss_trigger(run_time: float) -> void:
	# Boss at 10 minutes
	if run_time >= 600.0 and not _boss_10_spawned:
		_boss_10_spawned = true
		_spawn_boss("super_cellula", 2000.0)
		EventBus.screen_shake_requested.emit(8.0, 0.5)
	# Boss final at 20 minutes
	if run_time >= 1180.0 and not _boss_20_spawned:
		_boss_20_spawned = true
		_spawn_boss("prione", 5000.0)
		EventBus.screen_shake_requested.emit(10.0, 0.8)

func _spawn_boss(boss_id: String, hp: float) -> void:
	EventBus.boss_spawned.emit(boss_id)
	var player = get_tree().get_first_node_in_group("player")
	if player == null:
		return
	var boss_script := load("res://scripts/enemies/BossBase.gd")
	if boss_script == null:
		return
	var boss := CharacterBody2D.new()
	boss.set_script(boss_script)
	boss.boss_id = boss_id
	boss.max_health = hp * 1.5
	boss.base_max_health = hp * 1.5
	boss.current_health = hp * 1.5
	boss.contact_damage = 40.0
	boss.base_contact_damage = 40.0
	boss.move_speed = 80.0
	boss.exp_value = 150.0
	boss.global_position = player.global_position + Vector2(0, -500)
	get_parent().call_deferred("add_child", boss)
