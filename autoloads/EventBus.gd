## EventBus.gd
## Global signal bus — decouples all game systems.
## Usage: EventBus.player_died.emit()
extends Node

# ─── PLAYER ───────────────────────────────────────────────
signal player_died
signal player_damaged(amount: float, new_hp: float)
signal player_healed(amount: float, new_hp: float)
signal player_leveled_up(new_level: int)
signal player_exp_gained(amount: float, total: float, needed: float)

# ─── WEAPONS ──────────────────────────────────────────────
signal weapon_added(weapon_id: String)
signal weapon_leveled_up(weapon_id: String, new_level: int)
signal weapon_evolved(weapon_id: String, evolved_id: String)

# ─── ENEMIES ──────────────────────────────────────────────
signal enemy_died(enemy_type: String, position: Vector2)
signal enemy_spawned(enemy_type: String)
signal boss_spawned(boss_id: String)
signal boss_died(boss_id: String)

# ─── UPGRADE ──────────────────────────────────────────────
signal upgrade_selected(upgrade_id: String)
signal upgrade_choices_ready(choices: Array)

# ─── GAME STATE ───────────────────────────────────────────
signal run_started
signal run_ended(stats: Dictionary)
signal game_paused
signal game_resumed
signal wave_changed(minute: int)

# ─── UI ───────────────────────────────────────────────────
signal show_floating_text(text: String, position: Vector2, color: Color)
signal screen_shake_requested(intensity: float, duration: float)
