## SettingsMenu.gd
class_name SettingsMenu
extends Control

signal back_pressed

const COLOR_CYAN := Color(0.0, 0.8, 1.0, 1.0)
const COLOR_WHITE := Color("#FFFFFF")

var _sfx_slider: HSlider
var _music_slider: HSlider

func _ready() -> void:
	_build_ui()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		_on_back_pressed()

func _build_ui() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	set_anchors_preset(Control.PRESET_FULL_RECT)
	
	var bg = ColorRect.new()
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.color = Color(0.02, 0.05, 0.1, 1.0)
	add_child(bg)
	
	var top_bar = HBoxContainer.new()
	top_bar.set_anchors_preset(Control.PRESET_TOP_WIDE)
	top_bar.custom_minimum_size = Vector2(0, 100)
	top_bar.offset_top = 20
	top_bar.offset_left = 30
	top_bar.offset_right = -30
	top_bar.add_theme_constant_override("separation", 20)
	add_child(top_bar)
	
	var back_btn = Button.new()
	back_btn.text = "◀ INDIETRO"
	back_btn.custom_minimum_size = Vector2(160, 70)
	back_btn.pressed.connect(_on_back_pressed)
	_style_nav_button(back_btn)
	top_bar.add_child(back_btn)
	
	var spacer = Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	top_bar.add_child(spacer)
	
	var title = Label.new()
	title.text = "⚙️ IMPOSTAZIONI"
	title.add_theme_font_size_override("font_size", 48)
	title.add_theme_color_override("font_color", COLOR_WHITE)
	title.add_theme_color_override("font_outline_color", COLOR_CYAN.darkened(0.3))
	title.add_theme_constant_override("outline_size", 8)
	title.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	top_bar.add_child(title)
	
	spacer = Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	top_bar.add_child(spacer)
	
	var content = VBoxContainer.new()
	content.set_anchors_preset(Control.PRESET_FULL_RECT)
	content.offset_top = 120
	content.offset_left = 20
	content.offset_right = -20
	content.offset_bottom = -20
	content.add_theme_constant_override("separation", 24)
	content.size_flags_vertical = Control.SIZE_EXPAND_FILL
	content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	content.alignment = BoxContainer.ALIGNMENT_CENTER
	add_child(content)
	
	var sfx_label = Label.new()
	sfx_label.text = "🔊 Volume SFX"
	sfx_label.add_theme_font_size_override("font_size", 28)
	sfx_label.add_theme_color_override("font_color", COLOR_WHITE)
	content.add_child(sfx_label)
	
	_sfx_slider = _create_slider()
	_sfx_slider.value = _get_setting("sfx_volume", 1.0)
	_sfx_slider.value_changed.connect(_on_sfx_changed)
	content.add_child(_sfx_slider)
	
	var music_label = Label.new()
	music_label.text = "🎵 Volume Musica"
	music_label.add_theme_font_size_override("font_size", 28)
	music_label.add_theme_color_override("font_color", COLOR_WHITE)
	content.add_child(music_label)
	
	_music_slider = _create_slider()
	_music_slider.value = _get_setting("music_volume", 1.0)
	_music_slider.value_changed.connect(_on_music_changed)
	content.add_child(_music_slider)
	
	var vib_container = HBoxContainer.new()
	vib_container.add_theme_constant_override("separation", 20)
	content.add_child(vib_container)
	
	var vib_label = Label.new()
	vib_label.text = "📳 Vibrazione"
	vib_label.add_theme_font_size_override("font_size", 28)
	vib_label.add_theme_color_override("font_color", COLOR_WHITE)
	vib_container.add_child(vib_label)
	
	var vib_check = CheckButton.new()
	vib_check.button_pressed = _get_setting("vibration", true)
	vib_check.toggled.connect(_on_vibration_toggled)
	_style_checkbox(vib_check)
	vib_container.add_child(vib_check)

func _create_slider() -> HSlider:
	var slider = HSlider.new()
	slider.custom_minimum_size = Vector2(500, 40)
	slider.min_value = 0.0
	slider.max_value = 1.0
	slider.step = 0.05
	
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.1, 0.1, 0.15, 0.9)
	style.set_corner_radius_all(8)
	slider.add_theme_stylebox_override("background", style)
	
	var grabber = StyleBoxFlat.new()
	grabber.bg_color = COLOR_CYAN
	grabber.set_corner_radius_all(10)
	slider.add_theme_stylebox_override("grabber_area", grabber)
	slider.add_theme_stylebox_override("grabber_area_highlight", grabber)
	
	return slider

func _style_nav_button(btn: Button) -> void:
	btn.add_theme_font_size_override("font_size", 24)
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.0, 0.15, 0.25, 0.95)
	style.set_corner_radius_all(20)
	style.border_width_left = 3
	style.border_width_right = 3
	style.border_width_top = 3
	style.border_width_bottom = 3
	style.border_color = COLOR_CYAN
	btn.add_theme_stylebox_override("normal", style)
	btn.add_theme_stylebox_override("hover", style)

func _style_checkbox(cb: CheckButton) -> void:
	cb.add_theme_font_size_override("font_size", 24)

func _get_setting(key: String, default_value) -> Variant:
	if has_node("/root/SaveManager"):
		return get_node("/root/SaveManager").get_setting(key, default_value)
	return default_value

func _set_setting(key: String, value: Variant) -> void:
	if has_node("/root/SaveManager"):
		get_node("/root/SaveManager").set_setting(key, value)

func _on_sfx_changed(value: float) -> void:
	_set_setting("sfx_volume", value)

func _on_music_changed(value: float) -> void:
	_set_setting("music_volume", value)

func _on_vibration_toggled(toggled: bool) -> void:
	_set_setting("vibration", toggled)

func _on_back_pressed() -> void:
	back_pressed.emit()
	queue_free()