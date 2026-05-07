## UpgradeSystem.gd
## Manages the upgrade pool, rarity weights, and level-up selection.
class_name UpgradeSystem
extends Node

# ─── ALL UPGRADE DEFINITIONS ──────────────────────────────
const UPGRADES := {
	# STAT UPGRADES
	"hp_up_1":      {"name": "Stronger Membrane",   "desc": "+20 Max HP",             "rarity": "common",  "max_stack": 3, "stat": "max_health",  "value": 20.0},
	"hp_up_2":      {"name": "Reinforced Wall",      "desc": "+30 Max HP",             "rarity": "rare",    "max_stack": 2, "stat": "max_health",  "value": 30.0},
	"speed_up":     {"name": "Cytoplasm Flow",       "desc": "+15% Move Speed",        "rarity": "common",  "max_stack": 3, "stat": "move_speed",  "value": 30.0},
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
	# SPECIAL - NEW
	"lifesteal":    {"name": "Vampiric Tendril",    "desc": "+5% Life Steal",         "rarity": "epic",    "max_stack": 2, "stat": "lifesteal",   "value": 0.05},
	"thorns":      {"name": "Spiky Membrane",     "desc": "Enemies take 5 DMG when hitting", "rarity": "rare", "max_stack": 3, "stat": "thorns",      "value": 5.0},
	"dodge":      {"name": "Slippery Surface",    "desc": "+10% Dodge Chance",      "rarity": "epic",    "max_stack": 2, "stat": "dodge",       "value": 0.10},
	"explosion":   {"name": "Volatile Cell",       "desc": "+20% Explosion Area",   "rarity": "rare",    "max_stack": 3, "stat": "explosion_area","value": 0.20},
	"speed_boost":  {"name": "Adrenaline",        "desc": "+30% Speed for 3s after kill", "rarity": "epic", "max_stack": 2, "stat": "speed_boost", "value": 0.30},
	# WEAPON UPGRADES - Get new weapons!
	"weapon_spike":   {"name": "Spike Launcher",    "desc": "FIRE SPIKES IN ALL DIRECTIONS", "rarity": "rare",  "max_stack": 1, "type": "weapon", "script": "res://scripts/player/weapons/SpikeShoot.gd"},
	"weapon_shotgun": {"name": "Shotgun Blast",     "desc": "FIRE BURSTS OF PELLETS", "rarity": "rare",   "max_stack": 1, "type": "weapon", "script": "res://scripts/player/weapons/ShotgunBlast.gd"},
	"weapon_orbit":   {"name": "Plasma Orbit",     "desc": "ORBITING PLASMA ORBS", "rarity": "epic",    "max_stack": 1, "type": "weapon", "script": "res://scripts/player/weapons/PlasmaOrbit.gd"},
	# HEAL
	"heal_small":   {"name": "Glucose Injection",    "desc": "Recover 30 HP",          "rarity": "common",  "max_stack": 99, "type": "heal", "value": 30.0},
	"heal_big":     {"name": "Stem Cell Boost",      "desc": "Recover 60% Max HP",     "rarity": "rare",    "max_stack": 99, "type": "heal_percent", "value": 0.6},
	"heal_full":    {"name": "Full Restoration",   "desc": "Recover 100% Max HP",    "rarity": "epic",    "max_stack": 1,  "type": "heal_percent", "value": 1.0},
}

const RARITY_WEIGHTS := {
	"common": 70,
	"rare": 25,
	"epic": 5,
}

var _stacks: Dictionary = {}   # upgrade_id → current stack count
var _player: CharacterBody2D
var _obtained_weapons: Array = []  # Track obtained weapons


func setup(player: CharacterBody2D) -> void:
	_player = player
	_stacks.clear()
	_obtained_weapons.clear()


func get_choices(count: int = 3) -> Array:
	var available = _get_available_upgrades()
	print("Available upgrades: ", available.size())
	if available.is_empty():
		return []
	available.shuffle()
	var weighted = _apply_luck_to_pool(available)
	var choices: Array = []
	for up in weighted:
		if choices.size() >= count:
			break
		choices.append(up)
	print("Returning choices: ", choices.size())
	return choices


func apply_upgrade(upgrade_id: String) -> void:
	if not UPGRADES.has(upgrade_id):
		return
	var data: Dictionary = UPGRADES[upgrade_id]
	_stacks[upgrade_id] = _stacks.get(upgrade_id, 0) + 1

	var utype: String = data.get("type", "stat")
	match utype:
		"stat":
			var stat: String = data.get("stat", "")
			var value: float = float(data.get("value", 0))
			var is_percent: bool = data.get("is_percent", false)
			if stat != "" and stat in _player.stats:
				if is_percent:
					_player.stats[stat] += value
				else:
					_player.stats[stat] += value
				if stat == "max_health":
					_player.current_health = minf(_player.current_health + value, _player.stats.max_health)
		"heal":
			_player.heal(float(data.get("value", 0)))
		"heal_percent":
			_player.heal(_player.stats.max_health * float(data.get("value", 0)))
		"weapon":
			var script_path: String = data.get("script", "")
			if script_path != "":
				_add_weapon(script_path)

	# Note: upgrade_selected is emitted by World._on_upgrade_selected which called this.
	# Do NOT re-emit here to avoid infinite signal loop.


func _get_available_upgrades() -> Array:
	var result: Array = []
	for id in UPGRADES:
		var data = UPGRADES[id]
		var stack: int = _stacks.get(id, 0)
		# Skip if already obtained weapon
		if data.get("type") == "weapon" and data.get("script") in _obtained_weapons:
			continue
		if stack < int(data.get("max_stack", 1)):
			result.append({"id": id, "data": data})
	return result


func _apply_luck_to_pool(pool: Array) -> Array:
	var luck_stat: float = _player.stats.luck if _player else 0.0
	var common = []
	var rare = []
	var epic = []
	for u in pool:
		var rarity = u["data"]["rarity"]
		if rarity == "common":
			common.append(u)
		elif rarity == "rare":
			rare.append(u)
		elif rarity == "epic":
			epic.append(u)
	var weighted: Array = []
	if not epic.is_empty() and randf() < 0.05 + luck_stat * 0.2:
		weighted.append_array(epic)
	weighted.append_array(rare)
	weighted.append_array(common)
	weighted.shuffle()
	return weighted


func _add_weapon(script_path: String) -> void:
	var weapon_script = load(script_path)
	if weapon_script:
		_player.add_weapon(weapon_script)
		_obtained_weapons.append(script_path)
		EventBus.weapon_added.emit(script_path)
