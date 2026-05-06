## PlayerStats.gd
## All player statistics with their current values.
## Weapons and upgrades modify these values.
class_name PlayerStats
extends RefCounted

# ─── BASE STATS ───────────────────────────────────────────
var max_health: float = 100.0
var move_speed: float = 200.0

# ─── COMBAT MULTIPLIERS ───────────────────────────────────
var damage_mult: float = 1.0
var attack_speed_mult: float = 1.0
var area_mult: float = 1.0
var duration_mult: float = 1.0
var projectile_count: int = 0      # bonus projectiles added to all weapons
var piercing: int = 0              # bonus pierce count

# ─── SURVIVAL ─────────────────────────────────────────────
var armor: float = 0.0             # flat damage reduction
var regen: float = 0.0             # HP per second

# ─── ECONOMY ──────────────────────────────────────────────
var exp_gain_mult: float = 1.0
var pickup_radius: float = 80.0
var luck: float = 0.0              # affects upgrade rarity

# ─── CRIT ─────────────────────────────────────────────────
var crit_chance: float = 0.0       # 0.0 – 1.0
var crit_mult: float = 2.0


func apply_meta_upgrades() -> void:
	## Called at run start to bake meta-upgrade bonuses.
	max_health += SaveManager.get_meta_level("hp_up") * 10.0
	move_speed += SaveManager.get_meta_level("speed_up") * 5.0
	damage_mult += SaveManager.get_meta_level("damage_up") * 0.05
	exp_gain_mult += SaveManager.get_meta_level("exp_up") * 0.05
	armor += SaveManager.get_meta_level("armor_up") * 2.0
	regen += SaveManager.get_meta_level("regen_up") * 0.5
	pickup_radius += SaveManager.get_meta_level("magnet_up") * 10.0
	luck += SaveManager.get_meta_level("luck_up") * 0.05


func calculate_damage(base_damage: float) -> float:
	var dmg := base_damage * damage_mult
	if randf() < crit_chance:
		dmg *= crit_mult
	return dmg


func calculate_incoming_damage(raw: float) -> float:
	return max(1.0, raw - armor)
