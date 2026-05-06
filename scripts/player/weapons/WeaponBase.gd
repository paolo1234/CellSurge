## WeaponBase.gd
## Abstract base class for all weapons.
## Override _fire() in each weapon subclass.
class_name WeaponBase
extends Node2D

# ─── CONFIG (override per weapon) ─────────────────────────
@export var weapon_id: String = "weapon_base"
@export var base_damage: float = 10.0
@export var base_fire_rate: float = 1.0      # attacks per second
@export var base_area: float = 1.0
@export var max_level: int = 5
@export var level_ups: Array[Dictionary] = []

# ─── STATE ────────────────────────────────────────────────
var level: int = 1
var player: CharacterBody2D
var _fire_timer: float = 0.0


func _ready() -> void:
	_fire_timer = 1.0 / _get_fire_rate()   # stagger first shot


func _process(delta: float) -> void:
	if player == null or player.is_dead:
		return
	_fire_timer -= delta
	if _fire_timer <= 0.0:
		_fire_timer = 1.0 / _get_fire_rate()
		_fire()


# ─── TO OVERRIDE ──────────────────────────────────────────
func _fire() -> void:
	push_warning("WeaponBase._fire() not overridden in %s" % weapon_id)


# ─── HELPERS ──────────────────────────────────────────────
func _get_damage() -> float:
	if player:
		return player.stats.calculate_damage(base_damage * _get_level_mult("damage", 1.0))
	return base_damage


func _get_fire_rate() -> float:
	var mult := 1.0
	if player:
		mult = player.stats.attack_speed_mult
	return base_fire_rate * mult * _get_level_mult("fire_rate", 1.0)


func _get_area() -> float:
	var mult := 1.0
	if player:
		mult = player.stats.area_mult
	return base_area * mult * _get_level_mult("area", 1.0)


func _get_level_mult(stat: String, default_val: float) -> float:
	if level > 1 and level - 2 < level_ups.size():
		return level_ups[level - 2].get(stat, default_val)
	return default_val


func upgrade() -> void:
	if level < max_level:
		level += 1
		EventBus.weapon_leveled_up.emit(weapon_id, level)
