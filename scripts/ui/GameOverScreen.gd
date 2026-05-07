## GameOverScreen.gd
## Shown at the end of a run. Displays stats, restart, and return to menu.
## Bioluminescenza theme aligned with DESIGN_UI.md palette.
extends CanvasLayer

const COLOR_CYAN := Color("#00FFFF")
const COLOR_GREEN := Color("#39FF14")
const COLOR_RED := Color("#FF2400")
const COLOR_WHITE := Color("#F0F8FF")
const COLOR_GOLD := Color("#FFAC1C")

var _stats: Dictionary = {}
var _title: Label
var _time_val: Label
var _kills_val: Label
var _level_val: Label
var _gold_label: Label
var _gold_sub: Label
var _vbox: VBoxContainer


func _ready() -> void:
	hide()
	_build_ui()
	visibility_changed.connect(_on_visibility_changed)

func _on_visibility_changed() -> void:
	if not visible:
		_show_joysticks()


func _build_ui() -> void:
	layer = 200
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	# Dark overlay
	var overlay := ColorRect.new()
	overlay.color = Color(0.01, 0.01, 0.03, 0.92)
	overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(overlay)

	# Full-screen centered layout
	_vbox = VBoxContainer.new()
	_vbox.set_anchors_preset(Control.PRESET_FULL_RECT)
	_vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	_vbox.add_theme_constant_override("separation", 24)
	_vbox.offset_left = 60
	_vbox.offset_right = -60
	_vbox.offset_top = 100
	_vbox.offset_bottom = -100
	add_child(_vbox)

	# Title
	_title = Label.new()
	_title.text = "GAME OVER"
	_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_title.add_theme_font_size_override("font_size", 60)
	_title.add_theme_color_override("font_outline_color", Color.BLACK)
	_title.add_theme_constant_override("outline_size", 6)
	_title.add_theme_color_override("font_shadow_color", Color(1, 0, 0, 0.4))
	_title.add_theme_constant_override("shadow_outline_size", 20)
	_title.custom_minimum_size = Vector2(0, 100)
	_vbox.add_child(_title)

	# Stats panel
	var stats_panel := PanelContainer.new()
	var panel_style := StyleBoxFlat.new()
	panel_style.bg_color = Color(0.02, 0.06, 0.12, 0.85)
	panel_style.set_corner_radius_all(20)
	panel_style.border_width_left = 2
	panel_style.border_width_right = 2
	panel_style.border_width_top = 2
	panel_style.border_width_bottom = 2
	panel_style.border_color = Color(0, 0.4, 0.5, 0.5)
	panel_style.content_margin_left = 30
	panel_style.content_margin_right = 30
	panel_style.content_margin_top = 24
	panel_style.content_margin_bottom = 24
	stats_panel.add_theme_stylebox_override("panel", panel_style)
	_vbox.add_child(stats_panel)
	
	var stats_vbox := VBoxContainer.new()
	stats_vbox.add_theme_constant_override("separation", 16)
	stats_panel.add_child(stats_vbox)

	_time_val = _create_stat_label()
	stats_vbox.add_child(_create_stat_row("⏱  TEMPO", _time_val))

	_kills_val = _create_stat_label()
	stats_vbox.add_child(_create_stat_row("☠  UCCISIONI", _kills_val))

	_level_val = _create_stat_label()
	stats_vbox.add_child(_create_stat_row("🧬  LIVELLO", _level_val))

	# Gold earned panel
	var gold_panel := PanelContainer.new()
	var gold_style := StyleBoxFlat.new()
	gold_style.bg_color = Color(0.06, 0.04, 0.0, 0.7)
	gold_style.set_corner_radius_all(16)
	gold_style.border_width_left = 2
	gold_style.border_width_right = 2
	gold_style.border_width_top = 2
	gold_style.border_width_bottom = 2
	gold_style.border_color = Color(1, 0.67, 0.1, 0.4)
	gold_style.content_margin_left = 20
	gold_style.content_margin_right = 20
	gold_style.content_margin_top = 16
	gold_style.content_margin_bottom = 16
	gold_panel.add_theme_stylebox_override("panel", gold_style)
	_vbox.add_child(gold_panel)
	
	var gold_vbox := VBoxContainer.new()
	gold_vbox.add_theme_constant_override("separation", 6)
	gold_panel.add_child(gold_vbox)

	_gold_label = Label.new()
	_gold_label.text = "+0 💰"
	_gold_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_gold_label.add_theme_font_size_override("font_size", 48)
	_gold_label.add_theme_color_override("font_color", COLOR_GOLD)
	gold_vbox.add_child(_gold_label)

	_gold_sub = Label.new()
	_gold_sub.text = "GOLD GUADAGNATO"
	_gold_sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_gold_sub.add_theme_font_size_override("font_size", 16)
	_gold_sub.add_theme_color_override("font_color", Color(0.5, 0.5, 0.45))
	gold_vbox.add_child(_gold_sub)

	# Buttons
	var btn_spacer := Control.new()
	btn_spacer.custom_minimum_size = Vector2(0, 10)
	_vbox.add_child(btn_spacer)
	
	# Restart button
	var restart_btn := Button.new()
	restart_btn.text = "▶  GIOCA ANCORA"
	restart_btn.custom_minimum_size = Vector2(440, 80)
	restart_btn.add_theme_font_size_override("font_size", 28)
	restart_btn.add_theme_color_override("font_color", Color(0.05, 0.05, 0.05))
	restart_btn.process_mode = Node.PROCESS_MODE_ALWAYS
	restart_btn.pressed.connect(_on_restart_pressed)
	_style_solid_button(restart_btn, COLOR_CYAN)
	_vbox.add_child(restart_btn)

	# Menu button
	var menu_btn := Button.new()
	menu_btn.text = "🏠  TORNA AL MENU"
	menu_btn.custom_minimum_size = Vector2(440, 70)
	menu_btn.add_theme_font_size_override("font_size", 24)
	menu_btn.process_mode = Node.PROCESS_MODE_ALWAYS
	menu_btn.pressed.connect(_on_menu_pressed)
	_style_outline_button(menu_btn)
	_vbox.add_child(menu_btn)


func _create_stat_label() -> Label:
	var lbl := Label.new()
	lbl.add_theme_font_size_override("font_size", 36)
	lbl.add_theme_color_override("font_color", COLOR_WHITE)
	lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	return lbl


func _create_stat_row(label_text: String, value_lbl: Label) -> HBoxContainer:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 16)
	row.custom_minimum_size = Vector2(0, 50)

	var label := Label.new()
	label.text = label_text
	label.add_theme_font_size_override("font_size", 24)
	label.add_theme_color_override("font_color", Color(0.5, 0.6, 0.65))
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(label)

	row.add_child(value_lbl)
	return row


func _style_solid_button(btn: Button, color: Color) -> void:
	var style := StyleBoxFlat.new()
	style.bg_color = color
	style.set_corner_radius_all(18)
	style.shadow_color = color * Color(1, 1, 1, 0.3)
	style.shadow_size = 12
	
	var pressed := style.duplicate() as StyleBoxFlat
	pressed.bg_color = color.darkened(0.3)
	pressed.shadow_size = 4
	
	btn.add_theme_stylebox_override("normal", style)
	btn.add_theme_stylebox_override("hover", style)
	btn.add_theme_stylebox_override("pressed", pressed)
	btn.add_theme_stylebox_override("focus", StyleBoxEmpty.new())


func _style_outline_button(btn: Button) -> void:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0, 0, 0, 0.3)
	style.set_corner_radius_all(18)
	style.border_width_left = 3
	style.border_width_right = 3
	style.border_width_top = 3
	style.border_width_bottom = 3
	style.border_color = COLOR_CYAN
	
	btn.add_theme_stylebox_override("normal", style)
	btn.add_theme_stylebox_override("hover", style)
	btn.add_theme_stylebox_override("pressed", style)
	btn.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
	btn.add_theme_color_override("font_color", COLOR_WHITE)


func setup(stats: Dictionary) -> void:
	_stats = stats

	var victory: bool = stats.get("victory", false)
	if _title:
		_title.text = "🏆 VITTORIA!" if victory else "☠ GAME OVER"
		_title.add_theme_color_override("font_color", COLOR_GREEN if victory else COLOR_RED)
		_title.add_theme_color_override("font_shadow_color",
			Color(0.1, 1, 0.1, 0.3) if victory else Color(1, 0, 0, 0.3))

	var total_seconds: float = stats.get("time", 0.0)
	var minutes := int(total_seconds) / 60
	var seconds := int(total_seconds) % 60
	if _time_val:
		_time_val.text = "%02d:%02d" % [minutes, seconds]

	if _kills_val:
		_kills_val.text = "%d" % stats.get("kills", 0)

	if _level_val:
		_level_val.text = "%d" % stats.get("level", 1)

	if _gold_label:
		_gold_label.text = "+%d 💰" % stats.get("gold", 0)

	show()
	_hide_joysticks()
	get_tree().paused = true
	
	# Victory particle celebration
	if victory:
		var viewport_center := Vector2(540, 960)
		ParticleFactory.create_victory_burst(viewport_center, self)


func _on_restart_pressed() -> void:
	hide()
	get_tree().paused = false
	get_tree().reload_current_scene()


func _on_menu_pressed() -> void:
	hide()
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/ui/MainMenu.tscn")


func _hide_joysticks() -> void:
	if get_tree():
		get_tree().call_group("joysticks", "hide")

func _show_joysticks() -> void:
	if get_tree():
		get_tree().call_group("joysticks", "show")
