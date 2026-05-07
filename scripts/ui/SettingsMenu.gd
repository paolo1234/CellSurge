## SettingsMenu.gd
## Settings menu with volume controls and options.
extends Control

signal back_pressed

const COLOR_CYAN := Color("#00FFFF")
const COLOR_WHITE := Color("#F0F8FF")
const COLOR_GOLD := Color("#FFAC1C")

var _back_btn: Button
var _sfx_slider: HSlider
var _music_slider: HSlider
var _vibration_check: CheckButton


func _ready() -> void:
	_build_ui()
	set_process_input(true)


func _get_setting(key: String, default_value) -> Variant:
	if has_node("/root/SaveManager"):
		return get_node("/root/SaveManager").get_setting(key, default_value)
	return default_value


func _set_setting(key: String, value: Variant) -> void:
	if has_node("/root/SaveManager"):
		get_node("/root/SaveManager").set_setting(key, value)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		_on_back_pressed()


func _build_ui() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	set_anchors_preset(Control.PRESET_FULL_RECT)

	var bg := ColorRect.new()
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.color = Color(0.01, 0.01, 0.03, 0.98)
	add_child(bg)

	var center := CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(center)

	var main_vbox := VBoxContainer.new()
	main_vbox.custom_minimum_size = Vector2(500, 450)
	main_vbox.add_theme_constant_override("separation", 30)
	center.add_child(main_vbox)

	var title := Label.new()
	title.text = "⚙️ SETTINGS"
	title.add_theme_font_size_override("font_size", 48)
	title.modulate = COLOR_CYAN
	main_vbox.add_child(title)

	var sfx_container := VBoxContainer.new()
	sfx_container.add_theme_constant_override("separation", 10)
	main_vbox.add_child(sfx_container)

	var sfx_label := Label.new()
	sfx_label.text = "🔊 SFX Volume"
	sfx_label.add_theme_font_size_override("font_size", 24)
	sfx_label.modulate = COLOR_WHITE
	sfx_container.add_child(sfx_label)

	_sfx_slider = _create_slider()
	_sfx_slider.value = _get_setting("sfx_volume", 1.0)
	_sfx_slider.value_changed.connect(_on_sfx_changed)
	sfx_container.add_child(_sfx_slider)

	var music_container := VBoxContainer.new()
	music_container.add_theme_constant_override("separation", 10)
	main_vbox.add_child(music_container)

	var music_label := Label.new()
	music_label.text = "🎵 Music Volume"
	music_label.add_theme_font_size_override("font_size", 24)
	music_label.modulate = COLOR_WHITE
	music_container.add_child(music_label)

	_music_slider = _create_slider()
	_music_slider.value = _get_setting("music_volume", 1.0)
	_music_slider.value_changed.connect(_on_music_changed)
	music_container.add_child(_music_slider)

	var vib_container := HBoxContainer.new()
	vib_container.add_theme_constant_override("separation", 16)
	main_vbox.add_child(vib_container)

	var vib_label := Label.new()
	vib_label.text = "📳 Vibration"
	vib_label.add_theme_font_size_override("font_size", 24)
	vib_label.modulate = COLOR_WHITE
	vib_container.add_child(vib_label)

	_vibration_check = CheckButton.new()
	_vibration_check.button_pressed = _get_setting("vibration", true)
	_vibration_check.toggled.connect(_on_vibration_toggled)
	vib_container.add_child(_vibration_check)

	vib_container.add_child(Control.new())

	var spacer := Control.new()
	spacer.custom_minimum_size = Vector2(0, 40)
	main_vbox.add_child(spacer)

	var footer := HBoxContainer.new()
	footer.alignment = BoxContainer.ALIGNMENT_CENTER
	main_vbox.add_child(footer)

	_back_btn = Button.new()
	_back_btn.text = "◀  BACK"
	_back_btn.custom_minimum_size = Vector2(200, 60)
	_back_btn.pressed.connect(_on_back_pressed)

	_style_button(_back_btn)
	footer.add_child(_back_btn)


func _create_slider() -> HSlider:
	var slider := HSlider.new()
	slider.custom_minimum_size = Vector2(400, 30)
	slider.min_value = 0.0
	slider.max_value = 1.0
	slider.step = 0.05
	slider.value = 1.0

	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.1, 0.1, 0.15, 0.9)
	style.set_corner_radius_all(8)
	slider.add_theme_stylebox_override("background", style)

	var grabber_style := StyleBoxFlat.new()
	grabber_style.bg_color = COLOR_CYAN
	grabber_style.set_corner_radius_all(10)
	slider.add_theme_stylebox_override("grabber_area", grabber_style)
	slider.add_theme_stylebox_override("grabber_area_highlight", grabber_style)

	return slider


func _style_button(btn: Button) -> void:
	btn.add_theme_font_size_override("font_size", 22)

	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.04, 0.04, 0.08, 0.9)
	style.set_corner_radius_all(14)
	style.border_width_left = 2
	style.border_width_right = 2
	style.border_width_top = 2
	style.border_width_bottom = 2
	style.border_color = Color(0.3, 0.4, 0.5, 0.6)

	var hover := style.duplicate()
	hover.border_color = COLOR_CYAN

	btn.add_theme_stylebox_override("normal", style)
	btn.add_theme_stylebox_override("hover", hover)


func _on_sfx_changed(value: float) -> void:
	_set_setting("sfx_volume", value)


func _on_music_changed(value: float) -> void:
	_set_setting("music_volume", value)


func _on_vibration_toggled(toggled: bool) -> void:
	_set_setting("vibration", toggled)


func _on_back_pressed() -> void:
	back_pressed.emit()
	queue_free()