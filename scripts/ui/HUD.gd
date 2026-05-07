## HUD.gd
## In-game heads-up display — Bioluminescenza theme.
extends CanvasLayer

# ─── PALETTE ──────────────────────────────────────────────
const COLOR_CYAN     := Color(0.0, 0.898, 1.0, 1.0)        # #00E5FF
const COLOR_CYAN_DIM := Color(0.0, 0.898, 1.0, 0.4)
const COLOR_WHITE    := Color(0.941, 0.973, 1.0, 1.0)      # #F0F8FF
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
#  UI BUILD (REWRITTEN CON CONTAINER DINAMICI)
# ══════════════════════════════════════════════════════════════
func _build_ui() -> void:
	# Contenitore principale per le righe superiori
	var top_vbox := VBoxContainer.new()
	top_vbox.set_anchors_preset(Control.PRESET_TOP_WIDE)
	top_vbox.add_theme_constant_override("separation", 0)
	add_child(top_vbox)

	_build_top_bar(top_vbox)
	_build_header(top_vbox)
	
	_build_inventory()
	_build_vignette()


# ── RIGA 1: XP + PAUSA ────────────────────────────────────────
func _build_top_bar(parent: Container) -> void:
	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 16)
	margin.add_theme_constant_override("margin_right", 16)
	margin.add_theme_constant_override("margin_top", 16)
	margin.add_theme_constant_override("margin_bottom", 12)
	parent.add_child(margin)

	var hbox := HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 16)
	margin.add_child(hbox)

	# "XP" Label
	xp_label = Label.new()
	xp_label.text = "XP"
	xp_label.add_theme_font_size_override("font_size", 24)
	xp_label.add_theme_color_override("font_color", COLOR_CYAN)
	xp_label.add_theme_color_override("font_shadow_color", Color(0,0,0,0.5))
	xp_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	hbox.add_child(xp_label)

	# Barra XP Gigante
	exp_bar = ProgressBar.new()
	exp_bar.show_percentage = false
	exp_bar.max_value = 20.0
	exp_bar.value = 0.0
	exp_bar.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	exp_bar.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	exp_bar.custom_minimum_size = Vector2(0, 24)

	var bg_style := StyleBoxFlat.new()
	bg_style.bg_color = Color(0.0, 0.12, 0.24, 0.8)
	bg_style.border_color = COLOR_CYAN
	bg_style.set_border_width_all(2)
	bg_style.set_corner_radius_all(12)
	exp_bar.add_theme_stylebox_override("background", bg_style)

	var fill_style := StyleBoxFlat.new()
	fill_style.bg_color = COLOR_CYAN
	fill_style.set_corner_radius_all(10)
	fill_style.shadow_color = COLOR_CYAN_DIM
	fill_style.shadow_size = 6
	exp_bar.add_theme_stylebox_override("fill", fill_style)
	hbox.add_child(exp_bar)

	# Pulsante Pausa Perfettamente Rotondo
	pause_btn = Button.new()
	pause_btn.process_mode = Node.PROCESS_MODE_ALWAYS
	pause_btn.text = "⏸"
	pause_btn.add_theme_font_size_override("font_size", 20)
	pause_btn.custom_minimum_size = Vector2(42, 42)
	pause_btn.size_flags_vertical = Control.SIZE_SHRINK_CENTER

	var btn_style := StyleBoxFlat.new()
	btn_style.bg_color = Color(0.04, 0.16, 0.26, 0.9)
	btn_style.border_color = COLOR_CYAN
	btn_style.set_border_width_all(2)
	btn_style.set_corner_radius_all(21) 
	
	pause_btn.add_theme_stylebox_override("normal", btn_style)
	pause_btn.add_theme_stylebox_override("hover", btn_style)
	pause_btn.add_theme_stylebox_override("pressed", btn_style)
	pause_btn.add_theme_color_override("font_color", COLOR_CYAN)
	pause_btn.pressed.connect(_on_pause_pressed)
	hbox.add_child(pause_btn)


# ── RIGA 2: STATISTICHE (LV, Timer, Kill) ─────────────────────
func _build_header(parent: Container) -> void:
	var panel := PanelContainer.new()
	var panel_bg := StyleBoxFlat.new()
	panel_bg.bg_color = Color(0.0, 0.0, 0.0, 0.45) # Striscia scura dietro i numeri
	panel.add_theme_stylebox_override("panel", panel_bg)
	parent.add_child(panel)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 16)
	margin.add_theme_constant_override("margin_right", 16)
	margin.add_theme_constant_override("margin_top", 10)
	margin.add_theme_constant_override("margin_bottom", 10)
	panel.add_child(margin)

	var hbox := HBoxContainer.new()
	margin.add_child(hbox)

	# Livello
	level_label = Label.new()
	level_label.text = "LV 1"
	level_label.add_theme_font_size_override("font_size", 28)
	level_label.add_theme_color_override("font_color", COLOR_WHITE)
	level_label.add_theme_color_override("font_shadow_color", Color(0,0,0,0.8))
	level_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	level_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	hbox.add_child(level_label)

	# Timer
	timer_label = Label.new()
	timer_label.text = "00:00"
	timer_label.add_theme_font_size_override("font_size", 60)
	timer_label.add_theme_color_override("font_color", COLOR_WHITE)
	timer_label.add_theme_color_override("font_shadow_color", Color(0,0,0,0.8))
	timer_label.add_theme_constant_override("shadow_offset_y", 3)
	timer_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	timer_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	timer_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	hbox.add_child(timer_label)

	# Kill (Torna visibile perché usiamo SIZE_EXPAND_FILL sui nodi adiacenti)
	kills_label = Label.new()
	kills_label.text = "🦠 KILLS: 0"
	kills_label.add_theme_font_size_override("font_size", 22)
	kills_label.add_theme_color_override("font_color", COLOR_WHITE)
	kills_label.add_theme_color_override("font_shadow_color", Color(0,0,0,0.8))
	kills_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	kills_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	kills_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	hbox.add_child(kills_label)


# ── INVENTARIO (In basso a sinistra) ──────────────────────────
func _build_inventory() -> void:
	var margin_outer := MarginContainer.new()
	margin_outer.set_anchors_preset(Control.PRESET_BOTTOM_LEFT)
	margin_outer.grow_vertical = Control.GROW_DIRECTION_BEGIN
	margin_outer.grow_horizontal = Control.GROW_DIRECTION_END
	# Leggermente fuori schermo in basso a sinistra come un vero "blob"
	margin_outer.add_theme_constant_override("margin_left", -10)
	margin_outer.add_theme_constant_override("margin_bottom", -10)
	add_child(margin_outer)

	var blob_panel := PanelContainer.new()
	var blob_style := StyleBoxFlat.new()
	blob_style.bg_color = Color(0.04, 0.22, 0.40, 0.65)
	blob_style.border_color = COLOR_CYAN
	blob_style.set_border_width_all(3)
	# Curvature esagerate per la forma organica
	blob_style.corner_radius_top_right = 70
	blob_style.corner_radius_top_left = 16
	blob_style.corner_radius_bottom_right = 16
	blob_panel.add_theme_stylebox_override("panel", blob_style)
	margin_outer.add_child(blob_panel)

	# Margini interni per distanziare la griglia dai bordi del blob
	var margin_inner := MarginContainer.new()
	margin_inner.add_theme_constant_override("margin_left", 24)
	margin_inner.add_theme_constant_override("margin_right", 36)
	margin_inner.add_theme_constant_override("margin_top", 36)
	margin_inner.add_theme_constant_override("margin_bottom", 24)
	blob_panel.add_child(margin_inner)

	var grid := GridContainer.new()
	grid.columns = 3
	grid.add_theme_constant_override("h_separation", 16)
	grid.add_theme_constant_override("v_separation", 16)
	margin_inner.add_child(grid)

	# 6 Slot molto più grandi (75x75)
	for i in 6:
		var slot_root := Control.new()
		slot_root.custom_minimum_size = Vector2(75, 75) 

		var slot_style := StyleBoxFlat.new()
		slot_style.bg_color = COLOR_SLOT_BG
		slot_style.border_color = COLOR_SLOT_BORDER
		slot_style.set_border_width_all(3)
		slot_style.set_corner_radius_all(24)
		slot_style.shadow_color = COLOR_CYAN_DIM
		slot_style.shadow_size = 4

		var slot_panel := PanelContainer.new()
		slot_panel.add_theme_stylebox_override("panel", slot_style)
		slot_panel.set_anchors_preset(Control.PRESET_FULL_RECT)
		slot_root.add_child(slot_panel)

		var icon := Label.new()
		icon.text = "·"
		icon.add_theme_font_size_override("font_size", 42)
		icon.add_theme_color_override("font_color", COLOR_CYAN_DIM)
		icon.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		icon.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		icon.set_anchors_preset(Control.PRESET_FULL_RECT)
		slot_panel.add_child(icon)

		var badge := Label.new()
		badge.text = ""
		badge.add_theme_font_size_override("font_size", 16)
		badge.add_theme_color_override("font_color", COLOR_WHITE)
		badge.add_theme_color_override("font_outline_color", Color(0,0,0,1))
		badge.add_theme_constant_override("outline_size", 5)
		badge.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		badge.vertical_alignment = VERTICAL_ALIGNMENT_TOP
		badge.set_anchors_preset(Control.PRESET_TOP_RIGHT)
		badge.offset_left = -30.0
		badge.offset_top = 4.0
		badge.offset_right = -8.0
		badge.offset_bottom = 24.0
		badge.z_index = 2
		slot_root.add_child(badge)

		grid.add_child(slot_root)
		inventory_slots.append({"panel": slot_panel, "badge": badge, "icon": icon})


# ── VIGNETTE HP BASSI ─────────────────────────────────────────
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
	white.set_corner_radius_all(10)
	exp_bar.add_theme_stylebox_override("fill", white)
	await get_tree().create_timer(0.12).timeout
	var fill := StyleBoxFlat.new()
	fill.bg_color = COLOR_CYAN
	fill.set_corner_radius_all(10)
	fill.shadow_color = COLOR_CYAN_DIM
	fill.shadow_size = 6
	exp_bar.add_theme_stylebox_override("fill", fill)

func _start_vignette_pulse() -> void:
	if _vignette_tween and _vignette_tween.is_running(): return
	vignette.visible = true
	_vignette_tween = create_tween()
	_vignette_tween.set_loops(0)
	_vignette_tween.tween_property(vignette, "color", Color(1.0, 0.0, 0.0, 0.18), 0.55)
	_vignette_tween.tween_property(vignette, "color", Color(1.0, 0.0, 0.0, 0.03), 0.55)

func _stop_vignette_pulse() -> void:
	if _vignette_tween: _vignette_tween.kill()
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

func set_slot(index: int, icon_text: String, badge_num: int = 0) -> void:
	if index < 0 or index >= inventory_slots.size(): return
	var s: Dictionary = inventory_slots[index]
	s["icon"].text  = icon_text
	s["icon"].add_theme_font_size_override("font_size", 42)
	s["icon"].add_theme_color_override("font_color", COLOR_WHITE)
	s["badge"].text = str(badge_num) if badge_num > 0 else ""