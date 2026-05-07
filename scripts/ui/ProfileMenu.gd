## ProfileMenu.gd
## Full-screen player profile with global stats and active upgrades.
class_name ProfileMenu
extends Control

signal back_pressed

const COLOR_CYAN := Color(0.0, 0.8, 1.0, 1.0)
const COLOR_WHITE := Color("#FFFFFF")
const COLOR_BG := Color(0.02, 0.05, 0.1, 1.0)
const COLOR_GOLD := Color(1.0, 0.67, 0.1, 1.0)

func _ready() -> void:
	_build_ui()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		_on_back_pressed()

func _build_ui() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	var bg := ColorRect.new()
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.color = COLOR_BG
	add_child(bg)
	# Top bar
	var top := HBoxContainer.new()
	top.set_anchors_preset(Control.PRESET_TOP_WIDE)
	top.custom_minimum_size = Vector2(0, 100)
	top.offset_top = 20
	top.offset_left = 30
	top.offset_right = -30
	top.add_theme_constant_override("separation", 20)
	add_child(top)
	var back := Button.new()
	back.text = "◀ INDIETRO"
	back.custom_minimum_size = Vector2(180, 70)
	back.pressed.connect(_on_back_pressed)
	_style_btn(back)
	top.add_child(back)
	var sp := Control.new()
	sp.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	top.add_child(sp)
	var title := Label.new()
	title.text = "👤 PROFILO"
	title.add_theme_font_size_override("font_size", 42)
	title.add_theme_color_override("font_color", COLOR_WHITE)
	title.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	top.add_child(title)
	var sp2 := Control.new()
	sp2.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	top.add_child(sp2)
	# Scroll area
	var scroll := ScrollContainer.new()
	scroll.set_anchors_preset(Control.PRESET_FULL_RECT)
	scroll.offset_top = 130
	scroll.offset_left = 40
	scroll.offset_right = -40
	scroll.offset_bottom = -40
	scroll.custom_minimum_size.y = 400
	add_child(scroll)
	var content := VBoxContainer.new()
	content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	content.add_theme_constant_override("separation", 24)
	scroll.add_child(content)
	# Gold
	var gold_panel := _create_panel()
	content.add_child(gold_panel)
	var gvbox := VBoxContainer.new()
	gvbox.add_theme_constant_override("separation", 8)
	gold_panel.add_child(gvbox)
	var glbl := Label.new()
	glbl.text = "💰 GOLD"
	glbl.add_theme_font_size_override("font_size", 20)
	glbl.add_theme_color_override("font_color", COLOR_GOLD)
	glbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	gvbox.add_child(glbl)
	var gval := Label.new()
	gval.text = "%d" % SaveManager.get_gold()
	gval.add_theme_font_size_override("font_size", 52)
	gval.add_theme_color_override("font_color", COLOR_GOLD)
	gval.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	gvbox.add_child(gval)
	# Stats section
	var stats_panel := _create_panel()
	content.add_child(stats_panel)
	var svbox := VBoxContainer.new()
	svbox.add_theme_constant_override("separation", 10)
	stats_panel.add_child(svbox)
	var stitle := Label.new()
	stitle.text = "📊 STATISTICHE GLOBALI"
	stitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	stitle.add_theme_font_size_override("font_size", 22)
	stitle.add_theme_color_override("font_color", COLOR_CYAN)
	svbox.add_child(stitle)
	var sgrid := GridContainer.new()
	sgrid.columns = 2
	sgrid.add_theme_constant_override("h_separation", 30)
	sgrid.add_theme_constant_override("v_separation", 12)
	svbox.add_child(sgrid)
	_add_stat(sgrid, "Miglior tempo", _format_time(SaveManager.get_setting("best_time", 0.0)))
	_add_stat(sgrid, "Max uccisioni", str(SaveManager.get_setting("best_kills", 0)))
	_add_stat(sgrid, "Partite giocate", str(SaveManager.get_setting("total_runs", 0)))
	_add_stat(sgrid, "Gold totale guadagnato", str(SaveManager.get_setting("total_gold_earned", 0)))
	# Meta upgrades owned
	var meta_panel := _create_panel()
	content.add_child(meta_panel)
	var mvbox := VBoxContainer.new()
	mvbox.add_theme_constant_override("separation", 10)
	meta_panel.add_child(mvbox)
	var mt := Label.new()
	mt.text = "🧬 META UPGRADE"
	mt.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	mt.add_theme_font_size_override("font_size", 22)
	mt.add_theme_color_override("font_color", COLOR_CYAN)
	mvbox.add_child(mt)
	var mgrid := GridContainer.new()
	mgrid.columns = 2
	mgrid.add_theme_constant_override("h_separation", 16)
	mgrid.add_theme_constant_override("v_separation", 12)
	mvbox.add_child(mgrid)
	var meta_ids := ["hp_up", "speed_up", "damage_up", "exp_up", "armor_up", "regen_up", "magnet_up", "luck_up"]
	var meta_names := ["❤️ Salute+", "🏃 Velocità+", "⚔️ Danno+", "✨ EXP+", "🛡️ Armatura+", "💚 Rigenerazione+", "🧲 Magnete+", "🍀 Fortuna+"]
	for i in meta_ids.size():
		var lv := SaveManager.get_meta_level(meta_ids[i])
		_add_stat(mgrid, meta_names[i], "Lv. %d" % lv)

func _create_panel() -> PanelContainer:
	var p := PanelContainer.new()
	p.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var s := StyleBoxFlat.new()
	s.bg_color = Color(0.02, 0.06, 0.12, 0.85)
	s.set_corner_radius_all(16)
	s.set_border_width_all(2)
	s.border_color = Color(0, 0.4, 0.5, 0.3)
	s.content_margin_left = 24
	s.content_margin_right = 24
	s.content_margin_top = 20
	s.content_margin_bottom = 20
	p.add_theme_stylebox_override("panel", s)
	return p

func _add_stat(grid: GridContainer, label: String, value: String) -> void:
	var l := Label.new()
	l.text = label
	l.add_theme_font_size_override("font_size", 22)
	l.add_theme_color_override("font_color", Color(0.5, 0.6, 0.65))
	l.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	grid.add_child(l)
	var v := Label.new()
	v.text = value
	v.add_theme_font_size_override("font_size", 24)
	v.add_theme_color_override("font_color", COLOR_WHITE)
	v.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	grid.add_child(v)

func _format_time(seconds: float) -> String:
	var m := int(seconds) / 60
	var s := int(seconds) % 60
	return "%02d:%02d" % [m, s]

func _style_btn(b: Button) -> void:
	b.add_theme_font_size_override("font_size", 24)
	b.add_theme_color_override("font_color", COLOR_WHITE)
	var s := StyleBoxFlat.new()
	s.bg_color = Color(0.0, 0.15, 0.25, 0.95)
	s.set_corner_radius_all(20)
	s.set_border_width_all(3)
	s.border_color = COLOR_CYAN
	b.add_theme_stylebox_override("normal", s)
	b.add_theme_stylebox_override("hover", s)

func _on_back_pressed() -> void:
	back_pressed.emit()
	queue_free()