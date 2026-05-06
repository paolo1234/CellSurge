## HUD.gd
## In-game heads-up display — Bioluminescenza theme.
## Builds all UI programmatically to match DESIGN_UI.md specification.
extends CanvasLayer

# ─── PALETTE (BIOLUMINESCENZA) ────────────────────────────
const COLOR_CYAN := Color("#00FFFF")
const COLOR_GREEN := Color("#39FF14")
const COLOR_RED := Color("#FF2400")
const COLOR_WHITE := Color("#F0F8FF")
const COLOR_DAMAGE := Color("#FFAC1C")

# ─── REFS (built in _build_ui) ───────────────────────────
var exp_bar: ProgressBar
var level_label: Label
var timer_label: Label
var kills_label: Label
var inventory_slots: Array = []
var vignette: ColorRect

# ─── STATE ────────────────────────────────────────────────
var current_hp: float = 100.0
var max_hp: float = 100.0
var current_exp: float = 0.0
var exp_needed: float = 20.0
var _vignette_tween: Tween


func _ready() -> void:
	_build_ui()
	EventBus.player_damaged.connect(_on_player_damaged)
	EventBus.player_healed.connect(_on_player_healed)
	EventBus.player_exp_gained.connect(_on_exp_gained)
	EventBus.player_leveled_up.connect(_on_leveled_up)
	EventBus.enemy_died.connect(_on_enemy_died)


func _process(_delta: float) -> void:
	if GameManager.run_active:
		timer_label.text = GameManager.get_run_time_string()


func _build_ui() -> void:
	# ── XP BAR (Top Edge, Pill Shape, 8px) ────────────────
	exp_bar = ProgressBar.new()
	exp_bar.show_percentage = false
	exp_bar.max_value = 20.0
	exp_bar.value = 0.0
	exp_bar.set_anchors_preset(Control.PRESET_TOP_WIDE)
	exp_bar.offset_left = 16.0
	exp_bar.offset_right = -16.0
	exp_bar.offset_top = 8.0
	exp_bar.offset_bottom = 16.0
	exp_bar.custom_minimum_size = Vector2(0, 8)

	var bg_style := StyleBoxFlat.new()
	bg_style.bg_color = Color(0.0, 0.15, 0.15, 0.5)
	bg_style.set_corner_radius_all(12)

	var fill_style := StyleBoxFlat.new()
	fill_style.bg_color = Color(0.0, 1.0, 1.0, 0.9)
	fill_style.set_corner_radius_all(10)

	exp_bar.add_theme_stylebox_override("background", bg_style)
	exp_bar.add_theme_stylebox_override("fill", fill_style)
	add_child(exp_bar)

	# ── HEADER ROW (Below XP bar, 16px margins) ──────────
	var header := HBoxContainer.new()
	header.set_anchors_preset(Control.PRESET_TOP_WIDE)
	header.offset_left = 24.0
	header.offset_right = -24.0
	header.offset_top = 24.0
	header.offset_bottom = 68.0
	add_child(header)

	# Level (Left) — Ciano
	level_label = Label.new()
	level_label.text = "LV 1"
	level_label.add_theme_font_size_override("font_size", 28)
	level_label.modulate = COLOR_CYAN
	level_label.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	level_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	header.add_child(level_label)

	var spacer1 := Control.new()
	spacer1.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(spacer1)

	# Timer (Center) — Largest text
	timer_label = Label.new()
	timer_label.text = "00:00"
	timer_label.add_theme_font_size_override("font_size", 38)
	timer_label.modulate = COLOR_WHITE
	timer_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	timer_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	header.add_child(timer_label)

	var spacer2 := Control.new()
	spacer2.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(spacer2)

	# Kills (Right) — Skull icon
	kills_label = Label.new()
	kills_label.text = "☠ 0"
	kills_label.add_theme_font_size_override("font_size", 28)
	kills_label.modulate = COLOR_WHITE
	kills_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	kills_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	kills_label.size_flags_horizontal = Control.SIZE_SHRINK_END
	header.add_child(kills_label)

	# ── INVENTORY GRID (Bottom-Left, 3x2, 32×32) ─────────
	var inv_anchor := Control.new()
	inv_anchor.set_anchors_preset(Control.PRESET_BOTTOM_LEFT)
	inv_anchor.offset_left = 16.0
	inv_anchor.offset_bottom = -20.0
	inv_anchor.offset_top = -100.0
	inv_anchor.offset_right = 140.0
	add_child(inv_anchor)

	var grid := GridContainer.new()
	grid.columns = 3
	grid.add_theme_constant_override("h_separation", 6)
	grid.add_theme_constant_override("v_separation", 6)
	inv_anchor.add_child(grid)

	for i in 6:
		var slot := ColorRect.new()
		slot.color = Color(0.0, 0.0, 0.0, 0.3)
		slot.custom_minimum_size = Vector2(32, 32)
		grid.add_child(slot)
		inventory_slots.append(slot)

	# ── LOW HP VIGNETTE ───────────────────────────────────
	vignette = ColorRect.new()
	vignette.color = Color(1.0, 0.0, 0.0, 0.0)
	vignette.set_anchors_preset(Control.PRESET_FULL_RECT)
	vignette.mouse_filter = Control.MOUSE_FILTER_IGNORE
	vignette.visible = false
	add_child(vignette)


# ─── SIGNAL CALLBACKS ────────────────────────────────────

func _on_player_damaged(_amount: float, new_hp: float) -> void:
	current_hp = new_hp
	if current_hp / max_hp < 0.2:
		_start_vignette_pulse()
	else:
		_stop_vignette_pulse()


func _on_player_healed(_amount: float, new_hp: float) -> void:
	current_hp = new_hp
	if current_hp / max_hp >= 0.2:
		_stop_vignette_pulse()


func _on_exp_gained(_amount: float, total: float, needed: float) -> void:
	current_exp = total
	exp_needed = needed
	_update_exp_display()


func _on_leveled_up(new_level: int) -> void:
	level_label.text = "LV %d" % new_level
	current_exp = 0.0
	exp_needed = 20.0 + (new_level - 1) * 10.0
	_update_exp_display()
	_flash_exp_bar()


func _on_enemy_died(_type: String, _pos: Vector2) -> void:
	kills_label.text = "☠ %d" % GameManager.kill_count


func _update_exp_display() -> void:
	if exp_bar:
		exp_bar.max_value = exp_needed
		exp_bar.value = current_exp


func _flash_exp_bar() -> void:
	var white_style := StyleBoxFlat.new()
	white_style.bg_color = Color(1.0, 1.0, 1.0, 0.95)
	white_style.set_corner_radius_all(10)
	exp_bar.add_theme_stylebox_override("fill", white_style)
	await get_tree().create_timer(0.1).timeout
	var fill_style := StyleBoxFlat.new()
	fill_style.bg_color = Color(0.0, 1.0, 1.0, 0.9)
	fill_style.set_corner_radius_all(10)
	exp_bar.add_theme_stylebox_override("fill", fill_style)


func _start_vignette_pulse() -> void:
	if _vignette_tween and _vignette_tween.is_running():
		return
	vignette.visible = true
	_vignette_tween = create_tween()
	_vignette_tween.set_loops(0)
	_vignette_tween.tween_property(vignette, "color", Color(1.0, 0.0, 0.0, 0.15), 0.6)
	_vignette_tween.tween_property(vignette, "color", Color(1.0, 0.0, 0.0, 0.03), 0.6)


func _stop_vignette_pulse() -> void:
	if _vignette_tween:
		_vignette_tween.kill()
	vignette.visible = false
	vignette.color = Color(1.0, 0.0, 0.0, 0.0)


func setup_bars(p_max_hp: float) -> void:
	max_hp = p_max_hp
	current_hp = p_max_hp
	current_exp = 0.0
	exp_needed = 20.0
	_update_exp_display()
	level_label.text = "LV 1"
	kills_label.text = "☠ 0"
