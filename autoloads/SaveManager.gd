## SaveManager.gd
## Handles persistence: gold, meta-upgrades, settings, statistics.
extends Node

const SAVE_PATH := "user://save.json"

var _data: Dictionary = {
	"gold": 0,
	"meta_upgrades": {},
	"settings": {},
	"stats": {
		"best_time": 0.0,
		"best_kills": 0,
		"total_runs": 0,
		"total_gold_earned": 0,
	},
	"unlocked": [],
}

func _ready() -> void:
	_load()

func _load() -> void:
	if FileAccess.file_exists(SAVE_PATH):
		var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
		var json := JSON.new()
		var err := json.parse(file.get_as_text())
		if err == OK and json.data is Dictionary:
			var loaded: Dictionary = json.data
			# Merge loaded data into defaults to handle new fields
			for key in loaded:
				_data[key] = loaded[key]
			# Ensure stats sub-dict has all keys
			if not _data.has("stats") or not _data["stats"] is Dictionary:
				_data["stats"] = {"best_time": 0.0, "best_kills": 0, "total_runs": 0, "total_gold_earned": 0}

func _save() -> void:
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	file.store_string(JSON.stringify(_data, "\t"))

# ─── GOLD ─────────────────────────────────────────────────
func get_gold() -> int:
	return int(_data.get("gold", 0))

func add_gold(amount: int) -> void:
	_data["gold"] = get_gold() + amount
	if _data.has("stats"):
		_data["stats"]["total_gold_earned"] = _data["stats"].get("total_gold_earned", 0) + amount
	_save()

func spend_gold(amount: int) -> bool:
	if get_gold() >= amount:
		_data["gold"] = get_gold() - amount
		_save()
		return true
	return false

# ─── META UPGRADES ────────────────────────────────────────
func get_meta_level(upgrade_id: String) -> int:
	var metas: Dictionary = _data.get("meta_upgrades", {})
	return int(metas.get(upgrade_id, 0))

func set_meta_level(upgrade_id: String, level: int) -> void:
	if not _data.has("meta_upgrades"):
		_data["meta_upgrades"] = {}
	_data["meta_upgrades"][upgrade_id] = level
	_save()

func buy_meta_upgrade(upgrade_id: String, cost: int) -> bool:
	if spend_gold(cost):
		set_meta_level(upgrade_id, get_meta_level(upgrade_id) + 1)
		return true
	return false

# ─── SETTINGS ─────────────────────────────────────────────
func get_setting(key: String, default_val = null) -> Variant:
	var settings: Dictionary = _data.get("settings", {})
	return settings.get(key, default_val)

func set_setting(key: String, value) -> void:
	if not _data.has("settings"):
		_data["settings"] = {}
	_data["settings"][key] = value
	_save()

# ─── STATS ────────────────────────────────────────────────
func update_best_stats(run_time: float, kills: int) -> void:
	if not _data.has("stats"):
		_data["stats"] = {}
	if run_time > _data["stats"].get("best_time", 0.0):
		_data["stats"]["best_time"] = run_time
	if kills > _data["stats"].get("best_kills", 0):
		_data["stats"]["best_kills"] = kills
	_data["stats"]["total_runs"] = _data["stats"].get("total_runs", 0) + 1
	_save()

# ─── UNLOCKED ─────────────────────────────────────────────
func is_unlocked(item_id: String) -> bool:
	return item_id in _data.get("unlocked", [])

func unlock(item_id: String) -> void:
	if not _data.has("unlocked"):
		_data["unlocked"] = []
	if item_id not in _data["unlocked"]:
		_data["unlocked"].append(item_id)
		_save()
