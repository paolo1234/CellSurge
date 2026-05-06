## SaveManager.gd
## Handles all persistent data: gold, unlocks, meta-upgrades, settings.
extends Node

const SAVE_PATH := "user://save_data.json"

var data: Dictionary = {}

const DEFAULT_DATA := {
	"gold": 0,
	"gems": 0,
	"remove_ads": false,
	"unlocked_characters": ["leuco"],
	"selected_character": "leuco",
	"meta_upgrades": {},
	"best_time": 0.0,
	"best_kills": 0,
	"total_runs": 0,
	"daily_login": {"last_day": "", "streak": 0, "day_index": 0},
	"settings": {"sfx_volume": 1.0, "music_volume": 1.0, "vibration": true},
}


func _ready() -> void:
	load_data()


func load_data() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		data = DEFAULT_DATA.duplicate(true)
		save_data()
		return
	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	var json_text := file.get_as_text()
	file.close()
	var parsed = JSON.parse_string(json_text)
	if parsed is Dictionary:
		data = parsed
		# Merge defaults for any missing keys (forward compatibility)
		for key in DEFAULT_DATA:
			if not data.has(key):
				data[key] = DEFAULT_DATA[key]
	else:
		data = DEFAULT_DATA.duplicate(true)


func save_data() -> void:
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	file.store_string(JSON.stringify(data, "\t"))
	file.close()


# ─── GOLD ─────────────────────────────────────────────────
func get_gold() -> int:
	return data.get("gold", 0)


func add_gold(amount: int) -> void:
	data["gold"] = get_gold() + amount
	save_data()


func spend_gold(amount: int) -> bool:
	if get_gold() < amount:
		return false
	data["gold"] -= amount
	save_data()
	return true


# ─── GEMS ─────────────────────────────────────────────────
func get_gems() -> int:
	return data.get("gems", 0)


func add_gems(amount: int) -> void:
	data["gems"] = get_gems() + amount
	save_data()


func spend_gems(amount: int) -> bool:
	if get_gems() < amount:
		return false
	data["gems"] -= amount
	save_data()
	return true


# ─── META-UPGRADES ────────────────────────────────────────
func get_meta_level(upgrade_id: String) -> int:
	return data["meta_upgrades"].get(upgrade_id, 0)


func set_meta_level(upgrade_id: String, level: int) -> void:
	data["meta_upgrades"][upgrade_id] = level
	save_data()


func upgrade_meta(upgrade_id: String) -> void:
	var current := get_meta_level(upgrade_id)
	data["meta_upgrades"][upgrade_id] = current + 1
	save_data()


# ─── CHARACTERS ───────────────────────────────────────────
func is_character_unlocked(id: String) -> bool:
	return id in data.get("unlocked_characters", ["leuco"])


func unlock_character(id: String) -> void:
	if not is_character_unlocked(id):
		data["unlocked_characters"].append(id)
		save_data()


func get_selected_character() -> String:
	return data.get("selected_character", "leuco")


func set_selected_character(id: String) -> void:
	data["selected_character"] = id
	save_data()


# ─── BEST STATS ───────────────────────────────────────────
func update_best_stats(time: float, kills: int) -> void:
	if time > data.get("best_time", 0.0):
		data["best_time"] = time
	if kills > data.get("best_kills", 0):
		data["best_kills"] = kills
	data["total_runs"] = data.get("total_runs", 0) + 1
	save_data()


# ─── SETTINGS ─────────────────────────────────────────────
func get_setting(key: String, default_value = null):
	return data["settings"].get(key, default_value)


func set_setting(key: String, value) -> void:
	data["settings"][key] = value
	save_data()
