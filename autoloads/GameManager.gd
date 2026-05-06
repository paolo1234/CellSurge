## GameManager.gd
## Manages the current run state: timer, kills, score, level progression.
extends Node

# ─── RUN STATE ────────────────────────────────────────────
var run_active: bool = false
var run_time: float = 0.0          # seconds elapsed this run
var kill_count: int = 0
var damage_dealt: float = 0.0
var gold_earned_this_run: int = 0

# ─── EXP / LEVELING ───────────────────────────────────────
var current_exp: float = 0.0
var current_level: int = 1
var exp_to_next_level: float = 20.0

# ─── CONSTANTS ────────────────────────────────────────────
const BASE_EXP: float = 20.0
const EXP_GROWTH: float = 10.0        # added per level
const RUN_DURATION: float = 1200.0    # 20 minutes in seconds
const GOLD_PER_MINUTE: int = 10
const GOLD_PER_LEVEL: int = 5
const GOLD_BASE: int = 100


func _ready() -> void:
	EventBus.player_died.connect(_on_player_died)
	EventBus.enemy_died.connect(_on_enemy_died)
	EventBus.player_exp_gained.connect(_on_exp_gained)


func _process(delta: float) -> void:
	if not run_active:
		return
	run_time += delta


func start_run() -> void:
	run_active = true
	run_time = 0.0
	kill_count = 0
	damage_dealt = 0.0
	gold_earned_this_run = 0
	current_exp = 0.0
	current_level = 1
	exp_to_next_level = BASE_EXP
	EventBus.run_started.emit()


func end_run(victory: bool = false) -> void:
	run_active = false
	var gold = _calculate_gold(victory)
	gold_earned_this_run = gold
	SaveManager.add_gold(gold)
	var stats = {
		"time": run_time,
		"kills": kill_count,
		"level": current_level,
		"damage": damage_dealt,
		"gold": gold,
		"victory": victory,
	}
	EventBus.run_ended.emit(stats)


func add_exp(amount: float) -> void:
	if not run_active:
		return
	current_exp += amount
	EventBus.player_exp_gained.emit(amount, current_exp, exp_to_next_level)
	while current_exp >= exp_to_next_level:
		current_exp -= exp_to_next_level
		current_level += 1
		exp_to_next_level = BASE_EXP + (current_level - 1) * EXP_GROWTH
		EventBus.player_leveled_up.emit(current_level)


func register_damage(amount: float) -> void:
	damage_dealt += amount


func get_run_time_string() -> String:
	var minutes := int(run_time) / 60
	var seconds := int(run_time) % 60
	return "%02d:%02d" % [minutes, seconds]


func _calculate_gold(victory: bool) -> int:
	var gold := GOLD_BASE
	gold += int(run_time / 60.0) * GOLD_PER_MINUTE
	gold += current_level * GOLD_PER_LEVEL
	if victory:
		gold += 100
	return gold


func _on_player_died() -> void:
	end_run(false)


func _on_enemy_died(_type: String, _pos: Vector2) -> void:
	kill_count += 1


func _on_exp_gained(_amount: float, _total: float, _needed: float) -> void:
	pass  # handled in add_exp