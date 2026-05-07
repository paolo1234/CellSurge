## GameOverScreen.gd
## Shown at the end of a run. Displays stats and a restart button.
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


func _ready() -> void:
	hide()
	_build_ui()
	visibility_changed.connect(_on_visibility_changed)

func _on_visibility_changed() -> void:
	if not visible:
		_show_joysticks()


func _build_ui() -> void:
	layer = 200
	# Dark overlay
	var overlay := ColorRect.new()
	overlay.color = Color(0.01, 0.01, 0.03, 0.92)
	overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(overlay)

	# Glass panel - centered properly
	var panel := Panel.new()
	panel.set_anchors_preset(Control.PRESET_CENTER)
	panel.custom_minimum_size = Vector2(480, 520)
	panel.position = Vector2(-240, -260)

	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.03, 0.03, 0.08, 0.95)
	style.set_corner_radius_all(24)
	style.border_width_left = 2
	style.border_width_top = 2
	style.border_width_right = 2
	style.border_width_bottom = 2
	style.border_color = Color(0.0, 0.4, 0.4, 0.6)
	panel.add_theme_stylebox_override("panel", style)
	add_child(panel)

	var vbox := VBoxContainer.new()
	vbox.set_anchors_preset(Control.PRESET_FULL_RECT)
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	vbox.add_theme_constant_override("separation", 20)
	panel.add_child(vbox)

	# Title
	_title = Label.new()
	_title.text = "GAME OVER"
	_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_title.add_theme_font_size_override("font_size", 52)
	_title.modulate = COLOR_RED
	_title.custom_minimum_size = Vector2(0, 70)
	vbox.add_child(_title)

	# Stats
	var stats_container := VBoxContainer.new()
	stats_container.add_theme_constant_override("separation", 20)
	vbox.add_child(stats_container)

	_time_val = _create_stat_label()
	stats_container.add_child(_create_stat_row("⏱  TIME", _time_val))

	_kills_val = _create_stat_label()
	stats_container.add_child(_create_stat_row("☠  KILLS", _kills_val))

	_level_val = _create_stat_label()
	stats_container.add_child(_create_stat_row("🧬  LEVEL", _level_val))

	# Gold earned
	var gold_container := HBoxContainer.new()
	gold_container.alignment = BoxContainer.ALIGNMENT_CENTER
	gold_container.custom_minimum_size = Vector2(0, 70)
	vbox.add_child(gold_container)

	_gold_label = Label.new()
	_gold_label.text = "+0"
	_gold_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_gold_label.add_theme_font_size_override("font_size", 44)
	_gold_label.modulate = COLOR_GOLD
	gold_container.add_child(_gold_label)

	var gold_sub := Label.new()
	gold_sub.text = "  GOLD EARNED"
	gold_sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	gold_sub.add_theme_font_size_override("font_size", 18)
	gold_sub.modulate = Color(0.4, 0.45, 0.5)
	gold_container.add_child(gold_sub)

	# Restart button
	var restart_btn := Button.new()
	restart_btn.text = "▶  PLAY AGAIN"
	restart_btn.custom_minimum_size = Vector2(320, 72)
	restart_btn.add_theme_font_size_override("font_size", 26)
	restart_btn.add_theme_color_override("font_color", Color(0.05, 0.05, 0.05))
	restart_btn.process_mode = Node.PROCESS_MODE_ALWAYS
	restart_btn.pressed.connect(_on_restart_pressed)

	var btn_style := StyleBoxFlat.new()
	btn_style.bg_color = COLOR_CYAN
	btn_style.set_corner_radius_all(14)

	var btn_hover := btn_style.duplicate()
	btn_hover.bg_color = Color(0.4, 1.0, 1.0)

	restart_btn.add_theme_stylebox_override("normal", btn_style)
	restart_btn.add_theme_stylebox_override("hover", btn_hover)
	restart_btn.add_theme_stylebox_override("pressed", btn_style)
	restart_btn.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
	vbox.add_child(restart_btn)


func _create_stat_label() -> Label:
	var lbl := Label.new()
	lbl.add_theme_font_size_override("font_size", 32)
	lbl.modulate = COLOR_WHITE
	lbl.custom_minimum_size = Vector2(200, 0)
	return lbl


func _create_stat_row(label_text: String, value_lbl: Label) -> HBoxContainer:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 16)
	row.custom_minimum_size = Vector2(0, 50)

	var label := Label.new()
	label.text = label_text
	label.add_theme_font_size_override("font_size", 20)
	label.modulate = Color(0.4, 0.5, 0.55)
	label.custom_minimum_size = Vector2(160, 0)
	row.add_child(label)

	row.add_child(value_lbl)
	return row


func setup(stats: Dictionary) -> void:
	_stats = stats

	var victory: bool = stats.get("victory", false)
	if _title:
		_title.text = "VICTORY!" if victory else "GAME OVER"
		_title.modulate = COLOR_GREEN if victory else COLOR_RED

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
		_gold_label.text = "+%d" % stats.get("gold", 0)

	show()
	_hide_joysticks()
	get_tree().paused = true


func _on_restart_pressed() -> void:
	hide()
	get_tree().paused = false
	get_tree().reload_current_scene()


func _hide_joysticks() -> void:
	get_tree().call_group("joysticks", "hide")

func _show_joysticks() -> void:
	get_tree().call_group("joysticks", "show")
