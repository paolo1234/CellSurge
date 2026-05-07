## HUD.gd
## In-game heads-up display — Bioluminescenza theme.
extends CanvasLayer

const COLOR_CYAN     := Color(0.0, 0.898, 1.0, 1.0)
const COLOR_CYAN_DIM := Color(0.0, 0.898, 1.0, 0.4)
const COLOR_WHITE    := Color(0.941, 0.973, 1.0, 1.0)
const COLOR_SLOT_BG  := Color(0.04, 0.22, 0.40, 0.85)
const COLOR_SLOT_BORDER := Color(0.0, 0.898, 1.0, 0.6)
const COLOR_GOLD     := Color(1.0, 0.67, 0.1, 1.0)
const COLOR_RED      := Color(1.0, 0.2, 0.1, 1.0)

var exp_bar: ProgressBar
var xp_label: Label
var level_label: Label
var timer_label: Label
var kills_label: Label
var pause_btn: Button
var survival_bar: ProgressBar
var inventory_slots: Array = []
var vignette: ColorRect
var wave_announcement: Label
var boss_hp_bar: ProgressBar
var boss_hp_container: Control

var current_hp: float = 100.0
var max_hp: float = 100.0
var current_exp: float = 0.0
var exp_needed: float = 20.0
var _vignette_tween: Tween
var _wave_tween: Tween

func _ready() -> void:
	_build_ui()
	EventBus.player_damaged.connect(_on_player_damaged)
	EventBus.player_healed.connect(_on_player_healed)
	EventBus.player_exp_gained.connect(_on_exp_gained)
	EventBus.player_leveled_up.connect(_on_leveled_up)
	EventBus.enemy_died.connect(_on_enemy_died)
	EventBus.wave_announcement.connect(_on_wave_announcement)
	EventBus.boss_hp_changed.connect(_on_boss_hp_changed)
	EventBus.boss_died.connect(_on_boss_died)

func _process(_delta: float) -> void:
	if GameManager.run_active:
		var t := GameManager.get_run_time_string()
		timer_label.text = "%s / 20:00" % t
		var p := GameManager.run_progress
		if survival_bar: survival_bar.value = p
		# Color code timer
		if p >= 0.95:
			timer_label.add_theme_color_override("font_color", COLOR_RED)
			timer_label.modulate.a = 1.0 if fmod(GameManager.run_time, 1.0) < 0.5 else 0.6
		elif p >= 0.75:
			timer_label.add_theme_color_override("font_color", COLOR_GOLD)
			timer_label.modulate.a = 1.0
		else:
			timer_label.add_theme_color_override("font_color", COLOR_WHITE)
			timer_label.modulate.a = 1.0

func _build_ui() -> void:
	var top := VBoxContainer.new()
	top.set_anchors_preset(Control.PRESET_TOP_WIDE)
	top.add_theme_constant_override("separation", 0)
	add_child(top)
	_build_top_bar(top)
	_build_header(top)
	_build_survival_bar(top)
	_build_inventory()
	_build_vignette()
	_build_wave_label()
	_build_boss_bar()

func _build_top_bar(parent: Container) -> void:
	var m := MarginContainer.new()
	m.add_theme_constant_override("margin_left", 16)
	m.add_theme_constant_override("margin_right", 16)
	m.add_theme_constant_override("margin_top", 16)
	m.add_theme_constant_override("margin_bottom", 12)
	parent.add_child(m)
	var h := HBoxContainer.new()
	h.add_theme_constant_override("separation", 16)
	m.add_child(h)
	xp_label = Label.new()
	xp_label.text = "XP"
	xp_label.add_theme_font_size_override("font_size", 24)
	xp_label.add_theme_color_override("font_color", COLOR_CYAN)
	xp_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	h.add_child(xp_label)
	exp_bar = ProgressBar.new()
	exp_bar.show_percentage = false
	exp_bar.max_value = 20.0
	exp_bar.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	exp_bar.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	exp_bar.custom_minimum_size = Vector2(0, 24)
	var bg := StyleBoxFlat.new()
	bg.bg_color = Color(0.0, 0.12, 0.24, 0.8)
	bg.border_color = COLOR_CYAN
	bg.set_border_width_all(2)
	bg.set_corner_radius_all(12)
	exp_bar.add_theme_stylebox_override("background", bg)
	var fill := StyleBoxFlat.new()
	fill.bg_color = COLOR_CYAN
	fill.set_corner_radius_all(10)
	fill.shadow_color = COLOR_CYAN_DIM
	fill.shadow_size = 6
	exp_bar.add_theme_stylebox_override("fill", fill)
	h.add_child(exp_bar)
	pause_btn = Button.new()
	pause_btn.process_mode = Node.PROCESS_MODE_ALWAYS
	pause_btn.text = "⏸"
	pause_btn.add_theme_font_size_override("font_size", 20)
	pause_btn.custom_minimum_size = Vector2(42, 42)
	pause_btn.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	var bs := StyleBoxFlat.new()
	bs.bg_color = Color(0.04, 0.16, 0.26, 0.9)
	bs.border_color = COLOR_CYAN
	bs.set_border_width_all(2)
	bs.set_corner_radius_all(21)
	pause_btn.add_theme_stylebox_override("normal", bs)
	pause_btn.add_theme_stylebox_override("hover", bs)
	pause_btn.add_theme_stylebox_override("pressed", bs)
	pause_btn.add_theme_color_override("font_color", COLOR_CYAN)
	pause_btn.pressed.connect(_on_pause_pressed)
	h.add_child(pause_btn)

func _build_header(parent: Container) -> void:
	var panel := PanelContainer.new()
	var ps := StyleBoxFlat.new()
	ps.bg_color = Color(0, 0, 0, 0.45)
	panel.add_theme_stylebox_override("panel", ps)
	parent.add_child(panel)
	var m := MarginContainer.new()
	m.add_theme_constant_override("margin_left", 16)
	m.add_theme_constant_override("margin_right", 16)
	m.add_theme_constant_override("margin_top", 10)
	m.add_theme_constant_override("margin_bottom", 10)
	panel.add_child(m)
	var h := HBoxContainer.new()
	m.add_child(h)
	level_label = Label.new()
	level_label.text = "LV 1"
	level_label.add_theme_font_size_override("font_size", 28)
	level_label.add_theme_color_override("font_color", COLOR_WHITE)
	level_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	level_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	h.add_child(level_label)
	timer_label = Label.new()
	timer_label.text = "00:00 / 20:00"
	timer_label.add_theme_font_size_override("font_size", 40)
	timer_label.add_theme_color_override("font_color", COLOR_WHITE)
	timer_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	timer_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	timer_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	h.add_child(timer_label)
	kills_label = Label.new()
	kills_label.text = "🦠 0"
	kills_label.add_theme_font_size_override("font_size", 22)
	kills_label.add_theme_color_override("font_color", COLOR_WHITE)
	kills_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	kills_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	kills_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	h.add_child(kills_label)

func _build_survival_bar(parent: Container) -> void:
	var m := MarginContainer.new()
	m.add_theme_constant_override("margin_left", 16)
	m.add_theme_constant_override("margin_right", 16)
	m.add_theme_constant_override("margin_top", 4)
	m.add_theme_constant_override("margin_bottom", 4)
	parent.add_child(m)
	var h := HBoxContainer.new()
	h.add_theme_constant_override("separation", 10)
	m.add_child(h)
	var lbl := Label.new()
	lbl.text = "SURVIVAL"
	lbl.add_theme_font_size_override("font_size", 14)
	lbl.add_theme_color_override("font_color", COLOR_GOLD)
	lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	h.add_child(lbl)
	survival_bar = ProgressBar.new()
	survival_bar.show_percentage = false
	survival_bar.max_value = 1.0
	survival_bar.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	survival_bar.custom_minimum_size = Vector2(0, 12)
	var sbg := StyleBoxFlat.new()
	sbg.bg_color = Color(0.1, 0.06, 0.0, 0.6)
	sbg.set_corner_radius_all(6)
	sbg.border_color = COLOR_GOLD * Color(1, 1, 1, 0.4)
	sbg.set_border_width_all(1)
	survival_bar.add_theme_stylebox_override("background", sbg)
	var sf := StyleBoxFlat.new()
	sf.bg_color = COLOR_GOLD
	sf.set_corner_radius_all(5)
	survival_bar.add_theme_stylebox_override("fill", sf)
	h.add_child(survival_bar)

func _build_inventory() -> void:
	var mo := MarginContainer.new()
	mo.set_anchors_preset(Control.PRESET_BOTTOM_LEFT)
	mo.grow_vertical = Control.GROW_DIRECTION_BEGIN
	mo.grow_horizontal = Control.GROW_DIRECTION_END
	mo.add_theme_constant_override("margin_left", -10)
	mo.add_theme_constant_override("margin_bottom", -10)
	add_child(mo)
	var bp := PanelContainer.new()
	var bst := StyleBoxFlat.new()
	bst.bg_color = Color(0.04, 0.22, 0.40, 0.65)
	bst.border_color = COLOR_CYAN
	bst.set_border_width_all(3)
	bst.corner_radius_top_right = 70
	bst.corner_radius_top_left = 16
	bst.corner_radius_bottom_right = 16
	bp.add_theme_stylebox_override("panel", bst)
	mo.add_child(bp)
	var mi := MarginContainer.new()
	mi.add_theme_constant_override("margin_left", 24)
	mi.add_theme_constant_override("margin_right", 36)
	mi.add_theme_constant_override("margin_top", 36)
	mi.add_theme_constant_override("margin_bottom", 24)
	bp.add_child(mi)
	var grid := GridContainer.new()
	grid.columns = 3
	grid.add_theme_constant_override("h_separation", 16)
	grid.add_theme_constant_override("v_separation", 16)
	mi.add_child(grid)
	for i in 6:
		var sr := Control.new()
		sr.custom_minimum_size = Vector2(75, 75)
		var ss := StyleBoxFlat.new()
		ss.bg_color = COLOR_SLOT_BG
		ss.border_color = COLOR_SLOT_BORDER
		ss.set_border_width_all(3)
		ss.set_corner_radius_all(24)
		ss.shadow_color = COLOR_CYAN_DIM
		ss.shadow_size = 4
		var sp := PanelContainer.new()
		sp.add_theme_stylebox_override("panel", ss)
		sp.set_anchors_preset(Control.PRESET_FULL_RECT)
		sr.add_child(sp)
		var ic := Label.new()
		ic.text = "·"
		ic.add_theme_font_size_override("font_size", 42)
		ic.add_theme_color_override("font_color", COLOR_CYAN_DIM)
		ic.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		ic.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		ic.set_anchors_preset(Control.PRESET_FULL_RECT)
		sp.add_child(ic)
		var bd := Label.new()
		bd.text = ""
		bd.add_theme_font_size_override("font_size", 16)
		bd.add_theme_color_override("font_color", COLOR_WHITE)
		bd.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		bd.vertical_alignment = VERTICAL_ALIGNMENT_TOP
		bd.set_anchors_preset(Control.PRESET_TOP_RIGHT)
		bd.offset_left = -30.0
		bd.offset_top = 4.0
		bd.offset_right = -8.0
		bd.offset_bottom = 24.0
		bd.z_index = 2
		sr.add_child(bd)
		grid.add_child(sr)
		inventory_slots.append({"panel": sp, "badge": bd, "icon": ic})

func _build_vignette() -> void:
	vignette = ColorRect.new()
	vignette.color = Color(1, 0, 0, 0)
	vignette.set_anchors_preset(Control.PRESET_FULL_RECT)
	vignette.mouse_filter = Control.MOUSE_FILTER_IGNORE
	vignette.visible = false
	add_child(vignette)

func _build_wave_label() -> void:
	wave_announcement = Label.new()
	wave_announcement.set_anchors_preset(Control.PRESET_CENTER_TOP)
	wave_announcement.offset_top = 200
	wave_announcement.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	wave_announcement.add_theme_font_size_override("font_size", 36)
	wave_announcement.add_theme_color_override("font_color", COLOR_GOLD)
	wave_announcement.add_theme_color_override("font_outline_color", Color.BLACK)
	wave_announcement.add_theme_constant_override("outline_size", 4)
	wave_announcement.modulate.a = 0.0
	wave_announcement.grow_horizontal = Control.GROW_DIRECTION_BOTH
	add_child(wave_announcement)

func _build_boss_bar() -> void:
	boss_hp_container = Control.new()
	boss_hp_container.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	boss_hp_container.offset_bottom = -200
	boss_hp_container.offset_top = -240
	boss_hp_container.offset_left = 60
	boss_hp_container.offset_right = -60
	boss_hp_container.visible = false
	add_child(boss_hp_container)
	boss_hp_bar = ProgressBar.new()
	boss_hp_bar.show_percentage = false
	boss_hp_bar.set_anchors_preset(Control.PRESET_FULL_RECT)
	boss_hp_bar.custom_minimum_size = Vector2(0, 16)
	var bbg := StyleBoxFlat.new()
	bbg.bg_color = Color(0.15, 0.02, 0.02, 0.8)
	bbg.set_corner_radius_all(8)
	bbg.border_color = COLOR_RED * Color(1, 1, 1, 0.5)
	bbg.set_border_width_all(2)
	boss_hp_bar.add_theme_stylebox_override("background", bbg)
	var bf := StyleBoxFlat.new()
	bf.bg_color = COLOR_RED
	bf.set_corner_radius_all(6)
	boss_hp_bar.add_theme_stylebox_override("fill", bf)
	boss_hp_container.add_child(boss_hp_bar)

# ── SIGNALS ───────────────────────────────────────────────
func _on_player_damaged(_a: float, hp: float) -> void:
	current_hp = hp
	if current_hp / max_hp < 0.2: _start_vignette_pulse()
	else: _stop_vignette_pulse()

func _on_player_healed(_a: float, hp: float) -> void:
	current_hp = hp
	if current_hp / max_hp >= 0.2: _stop_vignette_pulse()

func _on_exp_gained(_a: float, total: float, needed: float) -> void:
	current_exp = total
	exp_needed = needed
	_update_exp()

func _on_leveled_up(lv: int) -> void:
	level_label.text = "LV %d" % lv
	current_exp = 0.0
	exp_needed = 20.0 + (lv - 1) * 10.0
	_update_exp()
	_flash_exp()

func _on_enemy_died(_t: String, _p: Vector2) -> void:
	kills_label.text = "🦠 %d" % GameManager.kill_count

func _on_pause_pressed() -> void:
	var ps := PauseScreen.new()
	add_child(ps)

func _on_wave_announcement(text: String, color: Color) -> void:
	if not wave_announcement: return
	wave_announcement.text = text
	wave_announcement.add_theme_color_override("font_color", color)
	if _wave_tween: _wave_tween.kill()
	wave_announcement.modulate.a = 0.0
	_wave_tween = create_tween()
	_wave_tween.tween_property(wave_announcement, "modulate:a", 1.0, 0.3)
	_wave_tween.tween_interval(2.0)
	_wave_tween.tween_property(wave_announcement, "modulate:a", 0.0, 0.5)

func _on_boss_hp_changed(cur: float, mx: float) -> void:
	boss_hp_container.visible = true
	boss_hp_bar.max_value = mx
	boss_hp_bar.value = cur

func _on_boss_died(_id: String) -> void:
	boss_hp_container.visible = false

# ── HELPERS ───────────────────────────────────────────────
func _update_exp() -> void:
	if exp_bar:
		exp_bar.max_value = exp_needed
		exp_bar.value = current_exp

func _flash_exp() -> void:
	var w := StyleBoxFlat.new()
	w.bg_color = Color(1, 1, 1, 0.95)
	w.set_corner_radius_all(10)
	exp_bar.add_theme_stylebox_override("fill", w)
	await get_tree().create_timer(0.12).timeout
	var f := StyleBoxFlat.new()
	f.bg_color = COLOR_CYAN
	f.set_corner_radius_all(10)
	f.shadow_color = COLOR_CYAN_DIM
	f.shadow_size = 6
	exp_bar.add_theme_stylebox_override("fill", f)

func _start_vignette_pulse() -> void:
	if _vignette_tween and _vignette_tween.is_running(): return
	vignette.visible = true
	_vignette_tween = create_tween()
	_vignette_tween.set_loops(0)
	_vignette_tween.tween_property(vignette, "color", Color(1, 0, 0, 0.18), 0.55)
	_vignette_tween.tween_property(vignette, "color", Color(1, 0, 0, 0.03), 0.55)

func _stop_vignette_pulse() -> void:
	if _vignette_tween: _vignette_tween.kill()
	vignette.visible = false
	vignette.color = Color(1, 0, 0, 0)

func setup_bars(p_max_hp: float) -> void:
	max_hp = p_max_hp
	current_hp = p_max_hp
	current_exp = 0.0
	exp_needed = 20.0
	_update_exp()
	level_label.text = "LV 1"
	kills_label.text = "🦠 0"

func set_slot(idx: int, icon_text: String, badge_num: int = 0) -> void:
	if idx < 0 or idx >= inventory_slots.size(): return
	var s: Dictionary = inventory_slots[idx]
	s["icon"].text = icon_text
	s["icon"].add_theme_font_size_override("font_size", 42)
	s["icon"].add_theme_color_override("font_color", COLOR_WHITE)
	s["badge"].text = str(badge_num) if badge_num > 0 else ""