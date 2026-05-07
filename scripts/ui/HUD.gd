## HUD.gd
## In-game heads-up display — Bioluminescenza theme.
## Layout matched to reference: XP bar top, header strip, inventory bottom-left.
extends CanvasLayer

# ─── PALETTE ──────────────────────────────────────────────
const COLOR_CYAN     := Color(0.0, 0.898, 1.0, 1.0)        # #00E5FF
const COLOR_CYAN_DIM := Color(0.0, 0.898, 1.0, 0.4)
const COLOR_WHITE    := Color(0.941, 0.973, 1.0, 1.0)      # #F0F8FF
const COLOR_KILLS    := Color(1.0, 0.835, 0.31, 1.0)       # #FFD54F warm gold
const COLOR_PANEL_BG := Color(0.04, 0.16, 0.26, 0.82)
const COLOR_SLOT_BG  := Color(0.04, 0.22, 0.40, 0.85)
const COLOR_SLOT_BORDER:= Color(0.0, 0.898, 1.0, 0.6)

# ─── REFS ─────────────────────────────────────────────────
var exp_bar      : ProgressBar
var xp_label     : Label
var level_label  : Label
var timer_label  : Label
var kills_label  : Label
var pause_btn    : Button
var inventory_slots : Array = []
var vignette     : ColorRect

# ─── STATE ────────────────────────────────────────────────
var current_hp   : float = 100.0
var max_hp       : float = 100.0
var current_exp  : float = 0.0
var exp_needed   : float = 20.0
var _vignette_tween : Tween


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


# ══════════════════════════════════════════════════════════════
#  UI BUILD
# ══════════════════════════════════════════════════════════════
func _build_ui() -> void:
	_build_top_bar()
	_build_header()
	_build_inventory()
	_build_vignette()


# ── TOP ROW (XP + Pause) ────────────────────────────────────
func _build_top_bar() -> void:
	var top_hbox := HBoxContainer.new()
	top_hbox.set_anchors_preset(Control.PRESET_TOP_WIDE)
	top_hbox.offset_left   = 16.0
	top_hbox.offset_right  = -16.0
	top_hbox.offset_top    = 16.0
	top_hbox.offset_bottom = 40.0
	top_hbox.add_theme_constant_override("separation", 16)
	add_child(top_hbox)

	# "XP" Label
	xp_label = Label.new()
	xp_label.text = "XP"
	xp_label.add_theme_font_size_override("font_size", 20)
	xp_label.add_theme_color_override("font_color", COLOR_CYAN)
	xp_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	top_hbox.add_child(xp_label)

	# XP Progress Bar
	exp_bar = ProgressBar.new()
	exp_bar.show_percentage = false
	exp_bar.max_value = 20.0
	exp_bar.value = 0.0
	exp_bar.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	exp_bar.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	exp_bar.custom_minimum_size = Vector2(0, 20)

	var bg_style := StyleBoxFlat.new()
	bg_style.bg_color = Color(0.0, 0.12, 0.24, 0.9)
	bg_style.border_color = COLOR_CYAN
	bg_style.set_border_width_all(2)
	bg_style.set_corner_radius_all(10) # Formato pillola
	exp_bar.add_theme_stylebox_override("background", bg_style)

	var fill_style := StyleBoxFlat.new()
	fill_style.bg_color = COLOR_CYAN
	fill_style.set_corner_radius_all(8)
	exp_bar.add_theme_stylebox_override("fill", fill_style)
	top_hbox.add_child(exp_bar)

	# Pause Button (Perfettamente tondo)
	pause_btn = Button.new()
	pause_btn.process_mode = Node.PROCESS_MODE_ALWAYS
	pause_btn.text = "⏸"
	pause_btn.add_theme_font_size_override("font_size", 16)
	pause_btn.custom_minimum_size = Vector2(36, 36)
	pause_btn.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	pause_btn.flat = true

	var btn_n := StyleBoxFlat.new()
	btn_n.bg_color     = Color(0.0, 0.12, 0.24, 0.9)
	btn_n.border_color = COLOR_CYAN
	btn_n.set_border_width_all(2)
	btn_n.set_corner_radius_all(18) 
	pause_btn.add_theme_stylebox_override("normal", btn_n)
	pause_btn.add_theme_stylebox_override("focus", btn_n)

	var btn_h := StyleBoxFlat.new()
	btn_h.bg_color     = Color(0.07, 0.32, 0.52, 0.95)
	btn_h.border_color = COLOR_CYAN
	btn_h.set_border_width_all(2)
	btn_h.set_corner_radius_all(18)
	pause_btn.add_theme_stylebox_override("hover",   btn_h)
	pause_btn.add_theme_stylebox_override("pressed", btn_h)

	pause_btn.add_theme_color_override("font_color",          COLOR_CYAN)
	pause_btn.add_theme_color_override("font_hover_color",    COLOR_WHITE)
	pause_btn.add_theme_color_override("font_pressed_color",  COLOR_WHITE)
	pause_btn.pressed.connect(_on_pause_pressed)
	top_hbox.add_child(pause_btn)


# ── SECOND ROW (Stats Header) ───────────────────────────────
func _build_header() -> void:
	# Rimossa la barra scura dritta, sostituta con ombre sui testi per replicare la pulizia del reference.
	var header := HBoxContainer.new()
	header.set_anchors_preset(Control.PRESET_TOP_WIDE)
	header.offset_left   = 16.0
	header.offset_right  = -16.0
	header.offset_top    = 60.0
	header.offset_bottom = 120.0
	header.add_theme_constant_override("separation", 4)
	add_child(header)

	# Level label
	level_label = Label.new()
	level_label.text = "LV 1"
	level_label.add_theme_font_size_override("font_size", 22)
	level_label.add_theme_color_override("font_color", COLOR_WHITE)
	level_label.add_theme_color_override("font_outline_color", Color(0, 0, 0, 1))
	level_label.add_theme_constant_override("outline_size", 6)
	level_label.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	level_label.vertical_alignment    = VERTICAL_ALIGNMENT_CENTER
	level_label.custom_minimum_size   = Vector2(80, 0)
	header.add_child(level_label)

	var sp1 := Control.new()
	sp1.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(sp1)

	# Timer (Gigante, centrato)
	timer_label = Label.new()
	timer_label.text = "00:00"
	timer_label.add_theme_font_size_override("font_size", 56) 
	timer_label.add_theme_color_override("font_color", COLOR_WHITE)
	timer_label.add_theme_color_override("font_outline_color", Color(0, 0, 0, 1))
	timer_label.add_theme_constant_override("outline_size", 8)
	timer_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	timer_label.vertical_alignment   = VERTICAL_ALIGNMENT_CENTER
	header.add_child(timer_label)

	var sp2 := Control.new()
	sp2.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(sp2)

	# Kills label
	kills_label = Label.new()
	kills_label.text = "🦠 KILLS: 0"
	kills_label.add_theme_font_size_override("font_size", 20)
	kills_label.add_theme_color_override("font_color", COLOR_WHITE)
	kills_label.add_theme_color_override("font_outline_color", Color(0, 0, 0, 1))
	kills_label.add_theme_constant_override("outline_size", 6)
	kills_label.horizontal_alignment  = HORIZONTAL_ALIGNMENT_RIGHT
	kills_label.vertical_alignment    = VERTICAL_ALIGNMENT_CENTER
	kills_label.size_flags_horizontal = Control.SIZE_SHRINK_END
	kills_label.custom_minimum_size   = Vector2(120, 0)
	header.add_child(kills_label)


# ── INVENTORY (bottom-left, 3×2 grid) ────────────────────────
func _build_inventory() -> void:
	# Pannello "Blob" organico dietro l'inventario
	var outer_style := StyleBoxFlat.new()
	outer_style.bg_color     = Color(0.04, 0.22, 0.40, 0.45)
	outer_style.border_color = Color(0.0, 0.898, 1.0, 0.3)
	outer_style.set_border_width_all(2)
	# Raggi diversi per simulare la forma organica del reference
	outer_style.corner_radius_top_left     = 20
	outer_style.corner_radius_top_right    = 40
	outer_style.corner_radius_bottom_right = 40
	outer_style.corner_radius_bottom_left  = 20
	
	outer_style.content_margin_left   = 16.0
	outer_style.content_margin_right  = 24.0
	outer_style.content_margin_top    = 24.0
	outer_style.content_margin_bottom = 20.0

	var inv_panel := PanelContainer.new()
	inv_panel.add_theme_stylebox_override("panel", outer_style)
	inv_panel.set_anchors_preset(Control.PRESET_BOTTOM_LEFT)
	inv_panel.offset_left   = -10.0 # Esce leggermente dallo schermo a sinistra
	inv_panel.offset_bottom = -16.0
	# Niente offset drastici: le dimensioni si adattano ai contenuti grandi
	add_child(inv_panel)

	var grid := GridContainer.new()
	grid.columns = 3
	grid.add_theme_constant_override("h_separation", 14)
	grid.add_theme_constant_override("v_separation", 14)
	inv_panel.add_child(grid)

	# 6 slots - Molto più grandi
	for i in 6:
		var slot_root := Control.new()
		slot_root.custom_minimum_size = Vector2(76, 76) 

		# Slot background panel "bubbly"
		var slot_style := StyleBoxFlat.new()
		slot_style.bg_color     = COLOR_SLOT_BG
		slot_style.border_color = COLOR_SLOT_BORDER
		slot_style.set_border_width_all(3)
		slot_style.set_corner_radius_all(22) # Molto curvo, quasi cerchio

		var slot_panel := PanelContainer.new()
		slot_panel.add_theme_stylebox_override("panel", slot_style)
		slot_panel.set_anchors_preset(Control.PRESET_FULL_RECT)
		slot_root.add_child(slot_panel)

		# Empty slot icon placeholder (dim dot)
		var icon := Label.new()
		icon.text = "·"
		icon.add_theme_font_size_override("font_size", 36)
		icon.add_theme_color_override("font_color", COLOR_CYAN_DIM)
		icon.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		icon.vertical_alignment   = VERTICAL_ALIGNMENT_CENTER
		icon.set_anchors_preset(Control.PRESET_FULL_RECT)
		slot_panel.add_child(icon)

		# Badge (top-right, shows item level)
		var badge := Label.new()
		badge.text = ""
		badge.add_theme_font_size_override("font_size", 16)
		badge.add_theme_color_override("font_color", COLOR_WHITE)
		badge.add_theme_color_override("font_outline_color", Color(0,0,0,0.8))
		badge.add_theme_constant_override("outline_size", 4)
		badge.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		badge.vertical_alignment   = VERTICAL_ALIGNMENT_TOP
		badge.set_anchors_preset(Control.PRESET_TOP_RIGHT)
		badge.offset_left   = -30.0
		badge.offset_top    = 4.0
		badge.offset_right  = -6.0
		badge.offset_bottom = 24.0
		badge.z_index = 2
		slot_root.add_child(badge)

		grid.add_child(slot_root)
		inventory_slots.append({"panel": slot_panel, "badge": badge, "icon": icon})


# ── LOW HP VIGNETTE ──────────────────────────────────────────
func _build_vignette() -> void:
	vignette = ColorRect.new()
	vignette.color = Color(1.0, 0.0, 0.0, 0.0)
	vignette.set_anchors_preset(Control.PRESET_FULL_RECT)
	vignette.mouse_filter = Control.MOUSE_FILTER_IGNORE
	vignette.visible = false
	add_child(vignette)


# ══════════════════════════════════════════════════════════════
#  SIGNAL CALLBACKS
# ══════════════════════════════════════════════════════════════
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
	exp_needed  = needed
	_update_exp_display()


func _on_leveled_up(new_level: int) -> void:
	level_label.text = "LV %d" % new_level
	current_exp = 0.0
	exp_needed  = 20.0 + (new_level - 1) * 10.0
	_update_exp_display()
	_flash_exp_bar()


func _on_enemy_died(_type: String, _pos: Vector2) -> void:
	kills_label.text = "🦠 KILLS: %d" % GameManager.kill_count


func _on_pause_pressed() -> void:
	get_tree().paused = !get_tree().paused
	pause_btn.text = "▶" if get_tree().paused else "⏸"


# ══════════════════════════════════════════════════════════════
#  HELPERS
# ══════════════════════════════════════════════════════════════
func _update_exp_display() -> void:
	if exp_bar:
		exp_bar.max_value = exp_needed
		exp_bar.value     = current_exp


func _flash_exp_bar() -> void:
	var white := StyleBoxFlat.new()
	white.bg_color = Color(1.0, 1.0, 1.0, 0.95)
	white.set_corner_radius_all(8)
	exp_bar.add_theme_stylebox_override("fill", white)
	await get_tree().create_timer(0.12).timeout
	var fill := StyleBoxFlat.new()
	fill.bg_color = COLOR_CYAN
	fill.set_corner_radius_all(8)
	exp_bar.add_theme_stylebox_override("fill", fill)


func _start_vignette_pulse() -> void:
	if _vignette_tween and _vignette_tween.is_running():
		return
	vignette.visible = true
	_vignette_tween = create_tween()
	_vignette_tween.set_loops(0)
	_vignette_tween.tween_property(vignette, "color", Color(1.0, 0.0, 0.0, 0.18), 0.55)
	_vignette_tween.tween_property(vignette, "color", Color(1.0, 0.0, 0.0, 0.03), 0.55)


func _stop_vignette_pulse() -> void:
	if _vignette_tween:
		_vignette_tween.kill()
	vignette.visible = false
	vignette.color = Color(1.0, 0.0, 0.0, 0.0)


# ── PUBLIC API ───────────────────────────────────────────────
func setup_bars(p_max_hp: float) -> void:
	max_hp      = p_max_hp
	current_hp  = p_max_hp
	current_exp = 0.0
	exp_needed  = 20.0
	_update_exp_display()
	level_label.text = "LV 1"
	kills_label.text = "🦠 KILLS: 0"


## Set slot icon and optional badge number (called by UpgradeSystem)
func set_slot(index: int, icon_text: String, badge_num: int = 0) -> void:
	if index < 0 or index >= inventory_slots.size():
		return
	var s: Dictionary = inventory_slots[index]
	s["icon"].text  = icon_text
	s["icon"].add_theme_font_size_override("font_size", 38)
	s["icon"].add_theme_color_override("font_color", COLOR_WHITE)
	s["badge"].text = str(badge_num) if badge_num > 0 else ""