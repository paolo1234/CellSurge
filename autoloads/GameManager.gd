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
const GOLD_PER_KILL: int = 5
const GOLD_PER_MINUTE: int = 10
const GOLD_PER_LEVEL: int = 5
const GOLD_BASE: int = 50

# ─── PROGRESS ─────────────────────────────────────────────
## Returns 0.0 → 1.0 progress toward 20 min victory
var run_progress: float:
	get:
		if RUN_DURATION <= 0.0:
			return 1.0
		return clampf(run_time / RUN_DURATION, 0.0, 1.0)


func _ready() -> void:
	EventBus.player_died.connect(_on_player_died)
	EventBus.enemy_died.connect(_on_enemy_died)
	EventBus.player_exp_gained.connect(_on_exp_gained)


func _process(delta: float) -> void:
	if not run_active:
		return
	run_time += delta
	_check_victory()

# Debug helper to add gold instantly (used by PauseScreen debug UI)
func add_gold_debug(amount: int) -> void:
	gold_earned_this_run += amount
	# No dedicated signal for gold changes; UI reads the value when needed



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
	if not run_active:
		return
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
	var actual_amount := amount
	# Apply exp gain multiplier from player stats
	var player = get_tree().get_first_node_in_group("player")
	if player and player.stats:
		actual_amount *= player.stats.exp_gain_mult
	current_exp += actual_amount
	EventBus.player_exp_gained.emit(actual_amount, current_exp, exp_to_next_level)
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


func get_remaining_time_string() -> String:
	var remaining := maxf(RUN_DURATION - run_time, 0.0)
	var minutes := int(remaining) / 60
	var seconds := int(remaining) % 60
	return "%02d:%02d" % [minutes, seconds]


func _check_victory() -> void:
	if run_time >= RUN_DURATION:
		end_run(true)


func _calculate_gold(victory: bool) -> int:
	var gold := GOLD_BASE
	gold += int(run_time / 60.0) * GOLD_PER_MINUTE
	gold += current_level * GOLD_PER_LEVEL
	gold += kill_count * GOLD_PER_KILL
	if victory:
		gold += 200  # Bonus vittoria
	return gold


func _on_player_died() -> void:
	end_run(false)


func _on_enemy_died(_type: String, _pos: Vector2) -> void:
	kill_count += 1


func _on_exp_gained(_amount: float, _total: float, _needed: float) -> void:
	pass  # handled in add_exp