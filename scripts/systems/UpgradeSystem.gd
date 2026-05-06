## UpgradeSystem.gd
## Manages the upgrade pool, rarity weights, and level-up selection.
class_name UpgradeSystem
extends Node

# ─── ALL UPGRADE DEFINITIONS ──────────────────────────────
const UPGRADES := {
	# STAT UPGRADES
	"hp_up_1":      {"name": "Stronger Membrane",   "desc": "+20 Max HP",             "rarity": "common",  "max_stack": 3, "stat": "max_health",  "value": 20.0},
	"hp_up_2":      {"name": "Reinforced Wall",      "desc": "+30 Max HP",             "rarity": "rare",    "max_stack": 2, "stat": "max_health",  "value": 30.0},
	"speed_up":     {"name": "Cytoplasm Flow",       "desc": "+15% Move Speed",        "rarity": "common",  "max_stack": 3, "stat": "move_speed",  "value": 0.15, "is_percent": true},
	"damage_up":    {"name": "Enzyme Boost",         "desc": "+10% Damage",            "rarity": "common",  "max_stack": 5, "stat": "damage_mult", "value": 0.10, "is_percent": true},
	"atk_speed_up": {"name": "Rapid Mitosis",        "desc": "+15% Attack Speed",      "rarity": "rare",    "max_stack": 3, "stat": "attack_speed_mult", "value": 0.15, "is_percent": true},
	"area_up":      {"name": "Cell Expansion",       "desc": "+20% Weapon Area",       "rarity": "rare",    "max_stack": 3, "stat": "area_mult",   "value": 0.20, "is_percent": true},
	"exp_up":       {"name": "Knowledge Absorption", "desc": "+20% EXP Gained",        "rarity": "common",  "max_stack": 3, "stat": "exp_gain_mult","value": 0.20, "is_percent": true},
	"regen_up":     {"name": "Cell Regeneration",    "desc": "+1 HP/s Regen",          "rarity": "rare",    "max_stack": 3, "stat": "regen",       "value": 1.0},
	"magnet_up":    {"name": "Ion Channel",          "desc": "+50 Pickup Radius",      "rarity": "common",  "max_stack": 2, "stat": "pickup_radius","value": 50.0},
	"armor_up":     {"name": "Keratin Shell",        "desc": "+5 Armor",               "rarity": "rare",    "max_stack": 3, "stat": "armor",       "value": 5.0},
	"crit_up":      {"name": "Unstable Nucleus",     "desc": "+5% Crit Chance",        "rarity": "epic",    "max_stack": 4, "stat": "crit_chance", "value": 0.05},
	"luck_up":      {"name": "Lucky Mutation",       "desc": "+5% Luck",               "rarity": "rare",    "max_stack": 3, "stat": "luck",        "value": 0.05},
	"pierce_up":    {"name": "Penetrating Strike",   "desc": "Projectiles pierce +1",  "rarity": "epic",    "max_stack": 2, "stat": "piercing",    "value": 1},
	"proj_up":      {"name": "Cell Division",        "desc": "+1 Projectile",          "rarity": "epic",    "max_stack": 3, "stat": "projectile_count", "value": 1},
	# HEAL
	"heal_small":   {"name": "Glucose Injection",    "desc": "Recover 30 HP",          "rarity": "common",  "max_stack": 99, "type": "heal", "value": 30.0},
	"heal_big":     {"name": "Stem Cell Boost",      "desc": "Recover 60% Max HP",     "rarity": "rare",    "max_stack": 99, "type": "heal_percent", "value": 0.6},
}

const RARITY_WEIGHTS := {
	"common": 70,
	"rare": 25,
	"epic": 5,
}

var _stacks: Dictionary = {}   # upgrade_id → current stack count
var _player: CharacterBody2D


func setup(player: CharacterBody2D) -> void:
	_player = player
	_stacks.clear()


func get_choices(count: int = 3) -> Array[Dictionary]:
	var available := _get_available_upgrades()
	available.shuffle()
	# Sort by weighted rarity
	var weighted := _apply_luck_to_pool(available)
	var choices: Array[Dictionary] = []
	for up in weighted:
		if choices.size() >= count:
			break
		choices.append(up)
	return choices


func apply_upgrade(upgrade_id: String) -> void:
	if not UPGRADES.has(upgrade_id):
		return
	var data := UPGRADES[upgrade_id]
	_stacks[upgrade_id] = _stacks.get(upgrade_id, 0) + 1

	var utype: String = data.get("type", "stat")
	match utype:
		"stat":
			var stat: String = data.get("stat", "")
			var value: float = float(data.get("value", 0))
			var is_percent: bool = data.get("is_percent", false)
			if stat in _player.stats and stat != "":
				if is_percent:
					_player.stats[stat] += _player.stats[stat] * value if stat.ends_with("_mult") else value
					# For multipliers, add flat bonus on top
					_player.stats[stat] = _player.stats.get(stat, 1.0) + value if stat.ends_with("_mult") else _player.stats.get(stat, 0.0) + value
				else:
					_player.stats[stat] += value
				# Special: max_health also restores HP
				if stat == "max_health":
					_player.current_health = minf(_player.current_health + value, _player.stats.max_health)
		"heal":
			_player.heal(float(data.get("value", 0)))
		"heal_percent":
			_player.heal(_player.stats.max_health * float(data.get("value", 0)))

	EventBus.upgrade_selected.emit(upgrade_id)


func _get_available_upgrades() -> Array:
	var result := []
	for id in UPGRADES:
		var data := UPGRADES[id]
		var stack := _stacks.get(id, 0)
		if stack < int(data.get("max_stack", 1)):
			result.append({"id": id, "data": data})
	return result


func _apply_luck_to_pool(pool: Array) -> Array:
	var luck := _player.stats.luck if _player else 0.0
	var common := pool.filter(func(u): return u["data"]["rarity"] == "common")
	var rare := pool.filter(func(u): return u["data"]["rarity"] == "rare")
	var epic := pool.filter(func(u): return u["data"]["rarity"] == "epic")
	# Luck shifts weight toward rarer items
	var total_weight := int(RARITY_WEIGHTS["common"] * (1.0 - luck))
	total_weight += RARITY_WEIGHTS["rare"]
	total_weight += int(RARITY_WEIGHTS["epic"] * (1.0 + luck * 5.0))
	var weighted: Array = []
	weighted.append_array(epic if randf() < 0.05 + luck * 0.2 else common)
	weighted.append_array(rare)
	weighted.append_array(common)
	weighted.shuffle()
	return weighted
