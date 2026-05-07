## SettingsMenu.gd
## Full-screen settings with volume sliders, vibration toggle.
class_name SettingsMenu
extends Control

signal back_pressed

const COLOR_CYAN := Color(0.0, 0.8, 1.0, 1.0)
const COLOR_WHITE := Color("#FFFFFF")
const COLOR_BG := Color(0.02, 0.05, 0.1, 1.0)

var _sfx_slider: HSlider
var _music_slider: HSlider
var _sfx_val: Label
var _music_val: Label

func _ready() -> void:
	_build_ui()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		_on_back_pressed()

func _build_ui() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
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
	title.text = "⚙️ IMPOSTAZIONI"
	title.add_theme_font_size_override("font_size", 42)
	title.add_theme_color_override("font_color", COLOR_WHITE)
	title.add_theme_color_override("font_outline_color", COLOR_CYAN.darkened(0.3))
	title.add_theme_constant_override("outline_size", 6)
	title.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	top.add_child(title)
	var sp2 := Control.new()
	sp2.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	top.add_child(sp2)
	# Scroll content
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
	content.add_theme_constant_override("separation", 30)
	scroll.add_child(content)
	# SFX
	var sfx_panel := _create_setting_panel()
	content.add_child(sfx_panel)
	var sfx_vbox := VBoxContainer.new()
	sfx_vbox.add_theme_constant_override("separation", 12)
	sfx_panel.add_child(sfx_vbox)
	var sfx_row := HBoxContainer.new()
	sfx_row.add_theme_constant_override("separation", 16)
	sfx_vbox.add_child(sfx_row)
	var sl := Label.new()
	sl.text = "🔊 Volume SFX"
	sl.add_theme_font_size_override("font_size", 28)
	sl.add_theme_color_override("font_color", COLOR_WHITE)
	sl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	sfx_row.add_child(sl)
	_sfx_val = Label.new()
	_sfx_val.add_theme_font_size_override("font_size", 28)
	_sfx_val.add_theme_color_override("font_color", COLOR_CYAN)
	sfx_row.add_child(_sfx_val)
	_sfx_slider = _create_slider()
	_sfx_slider.value = _load_setting("sfx_volume", 1.0)
	_sfx_val.text = "%d%%" % int(_sfx_slider.value * 100)
	_sfx_slider.value_changed.connect(func(v):
		_save_setting("sfx_volume", v)
		_sfx_val.text = "%d%%" % int(v * 100))
	sfx_vbox.add_child(_sfx_slider)
	# Music
	var music_panel := _create_setting_panel()
	content.add_child(music_panel)
	var mvbox := VBoxContainer.new()
	mvbox.add_theme_constant_override("separation", 12)
	music_panel.add_child(mvbox)
	var mrow := HBoxContainer.new()
	mrow.add_theme_constant_override("separation", 16)
	mvbox.add_child(mrow)
	var ml := Label.new()
	ml.text = "🎵 Volume Musica"
	ml.add_theme_font_size_override("font_size", 28)
	ml.add_theme_color_override("font_color", COLOR_WHITE)
	ml.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	mrow.add_child(ml)
	_music_val = Label.new()
	_music_val.add_theme_font_size_override("font_size", 28)
	_music_val.add_theme_color_override("font_color", COLOR_CYAN)
	mrow.add_child(_music_val)
	_music_slider = _create_slider()
	_music_slider.value = _load_setting("music_volume", 1.0)
	_music_val.text = "%d%%" % int(_music_slider.value * 100)
	_music_slider.value_changed.connect(func(v):
		_save_setting("music_volume", v)
		_music_val.text = "%d%%" % int(v * 100)
		if AudioManager.music_player:
			AudioManager.music_player.volume_db = linear_to_db(v) - 6.0)
	mvbox.add_child(_music_slider)
	# Vibration
	var vib_panel := _create_setting_panel()
	content.add_child(vib_panel)
	var vrow := HBoxContainer.new()
	vrow.add_theme_constant_override("separation", 20)
	vib_panel.add_child(vrow)
	var vl := Label.new()
	vl.text = "📳 Vibrazione"
	vl.add_theme_font_size_override("font_size", 28)
	vl.add_theme_color_override("font_color", COLOR_WHITE)
	vl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vrow.add_child(vl)
	var cb := CheckButton.new()
	cb.button_pressed = _load_setting("vibration", true)
	cb.toggled.connect(func(v): _save_setting("vibration", v))
	vrow.add_child(cb)

func _create_setting_panel() -> PanelContainer:
	var p := PanelContainer.new()
	p.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var s := StyleBoxFlat.new()
	s.bg_color = Color(0.02, 0.06, 0.12, 0.85)
	s.set_corner_radius_all(16)
	s.border_width_left = 2
	s.border_width_right = 2
	s.border_width_top = 2
	s.border_width_bottom = 2
	s.border_color = Color(0, 0.4, 0.5, 0.3)
	s.content_margin_left = 24
	s.content_margin_right = 24
	s.content_margin_top = 20
	s.content_margin_bottom = 20
	p.add_theme_stylebox_override("panel", s)
	return p

func _create_slider() -> HSlider:
	var s := HSlider.new()
	s.custom_minimum_size = Vector2(0, 50)
	s.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	s.min_value = 0.0
	s.max_value = 1.0
	s.step = 0.05
	var bg := StyleBoxFlat.new()
	bg.bg_color = Color(0.1, 0.1, 0.15, 0.9)
	bg.set_corner_radius_all(8)
	s.add_theme_stylebox_override("background", bg)
	var g := StyleBoxFlat.new()
	g.bg_color = COLOR_CYAN
	g.set_corner_radius_all(10)
	s.add_theme_stylebox_override("grabber_area", g)
	s.add_theme_stylebox_override("grabber_area_highlight", g)
	return s

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

func _load_setting(key: String, def) -> Variant:
	if has_node("/root/SaveManager"):
		return get_node("/root/SaveManager").get_setting(key, def)
	return def

func _save_setting(key: String, val: Variant) -> void:
	if has_node("/root/SaveManager"):
		get_node("/root/SaveManager").set_setting(key, val)

func _on_back_pressed() -> void:
	back_pressed.emit()
	queue_free()