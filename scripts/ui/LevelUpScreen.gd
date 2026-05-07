## LevelUpScreen.gd
## Pauses the game and presents upgrade choices vertically (portrait mode).
extends CanvasLayer

const COLOR_BG := Color(0.01, 0.01, 0.03, 0.92)
const COLOR_PANEL := Color(0.03, 0.03, 0.08, 0.95)
const COLOR_CYAN := Color("#00FFFF")
const COLOR_GOLD := Color("#FFAC1C")
const COLOR_WHITE := Color("#F0F8FF")
const COLOR_COMMON := Color(0.5, 0.6, 0.65)
const COLOR_RARE := Color(0.3, 0.5, 1.0)
const COLOR_EPIC := Color(0.6, 0.3, 0.9)

var _choice_buttons: Array = []
var _choices: Array = []

func _ready() -> void:
	_build_ui()
	visible = false
	visibility_changed.connect(_on_visibility_changed)

func _on_visibility_changed() -> void:
	if not visible:
		_show_joysticks()

func _build_ui() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	layer = 200
	var overlay := ColorRect.new()
	overlay.color = COLOR_BG
	overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(overlay)
	var main := VBoxContainer.new()
	main.set_anchors_preset(Control.PRESET_FULL_RECT)
	main.alignment = BoxContainer.ALIGNMENT_CENTER
	main.add_theme_constant_override("separation", 20)
	main.offset_left = 40
	main.offset_right = -40
	main.offset_top = 60
	main.offset_bottom = -60
	add_child(main)
	var title := Label.new()
	title.text = "⚡ LEVEL UP!"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 52)
	title.add_theme_color_override("font_color", COLOR_GOLD)
	title.add_theme_color_override("font_outline_color", Color.BLACK)
	title.add_theme_constant_override("outline_size", 4)
	title.add_theme_color_override("font_shadow_color", Color(1, 0.6, 0, 0.3))
	title.add_theme_constant_override("shadow_outline_size", 15)
	main.add_child(title)
	var sub := Label.new()
	sub.text = "Scegli una mutazione"
	sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	sub.add_theme_font_size_override("font_size", 22)
	sub.add_theme_color_override("font_color", Color(0.4, 0.5, 0.55))
	main.add_child(sub)
	# VERTICAL cards for portrait mode
	for i in 3:
		var card := _create_card(i)
		main.add_child(card)
		_choice_buttons.append(card)
		card.pressed.connect(_on_choice_pressed.bind(i))

func _create_card(_idx: int) -> Button:
	var card := Button.new()
	card.custom_minimum_size = Vector2(0, 160)
	card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	card.process_mode = Node.PROCESS_MODE_ALWAYS
	var style := StyleBoxFlat.new()
	style.bg_color = COLOR_PANEL
	style.set_corner_radius_all(20)
	style.set_border_width_all(3)
	style.border_color = Color(0.0, 0.3, 0.3, 0.5)
	style.content_margin_left = 20
	style.content_margin_right = 20
	style.content_margin_top = 16
	style.content_margin_bottom = 16
	var hover := style.duplicate() as StyleBoxFlat
	hover.border_color = COLOR_CYAN
	hover.bg_color = Color(0.04, 0.06, 0.12, 0.98)
	hover.shadow_color = Color(0, 1, 1, 0.15)
	hover.shadow_size = 10
	card.add_theme_stylebox_override("normal", style)
	card.add_theme_stylebox_override("hover", hover)
	card.add_theme_stylebox_override("pressed", style)
	card.add_theme_stylebox_override("disabled", style)
	card.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
	return card

func show_choices(choices: Array, _level: int) -> void:
	_choices = choices
	_hide_joysticks()
	if choices.is_empty():
		return
	for i in range(3):
		var card = _choice_buttons[i]
		for c in card.get_children():
			c.queue_free()
		if i < choices.size():
			var up = choices[i]
			var data = up.get("data", {})
			var upg_name = data.get("name", "Unknown")
			var desc = data.get("desc", "")
			var rarity = data.get("rarity", "common")
			# Horizontal layout inside card
			var hbox := HBoxContainer.new()
			hbox.add_theme_constant_override("separation", 20)
			hbox.set_anchors_preset(Control.PRESET_FULL_RECT)
			hbox.offset_left = 16
			hbox.offset_right = -16
			hbox.offset_top = 12
			hbox.offset_bottom = -12
			card.add_child(hbox)
			# Rarity colored bar on left
			var bar := ColorRect.new()
			bar.custom_minimum_size = Vector2(6, 0)
			bar.color = _get_rarity_color(rarity)
			bar.size_flags_vertical = Control.SIZE_EXPAND_FILL
			hbox.add_child(bar)
			# Text content
			var vbox := VBoxContainer.new()
			vbox.add_theme_constant_override("separation", 6)
			vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			vbox.alignment = BoxContainer.ALIGNMENT_CENTER
			hbox.add_child(vbox)
			var rarity_lbl := Label.new()
			rarity_lbl.text = rarity.to_upper()
			rarity_lbl.add_theme_font_size_override("font_size", 16)
			rarity_lbl.add_theme_color_override("font_color", _get_rarity_color(rarity))
			vbox.add_child(rarity_lbl)
			var name_lbl := Label.new()
			name_lbl.text = upg_name
			name_lbl.add_theme_font_size_override("font_size", 28)
			name_lbl.add_theme_color_override("font_color", COLOR_WHITE)
			name_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD
			vbox.add_child(name_lbl)
			var desc_lbl := Label.new()
			desc_lbl.text = desc
			desc_lbl.add_theme_font_size_override("font_size", 20)
			desc_lbl.add_theme_color_override("font_color", Color(0.5, 0.6, 0.65))
			desc_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD
			vbox.add_child(desc_lbl)
			# Update border color based on rarity
			var card_style := card.get_theme_stylebox("normal").duplicate() as StyleBoxFlat
			card_style.border_color = _get_rarity_color(rarity) * Color(1, 1, 1, 0.6)
			card.add_theme_stylebox_override("normal", card_style)
			card.visible = true
			card.disabled = false
		else:
			card.visible = false
	visible = true
	get_tree().paused = true
	if AudioManager and AudioManager.music_player:
		AudioManager.music_player.stream_paused = false

func _hide_joysticks() -> void:
	if get_tree(): get_tree().call_group("joysticks", "hide")

func _show_joysticks() -> void:
	if get_tree(): get_tree().call_group("joysticks", "show")

func _get_rarity_color(rarity: String) -> Color:
	match rarity:
		"rare": return COLOR_RARE
		"epic": return COLOR_EPIC
		_: return COLOR_COMMON

func _on_choice_pressed(index: int) -> void:
	get_tree().paused = false
	visible = false
	if index < _choices.size():
		var id = _choices[index].get("id", "")
		if id != "":
			EventBus.upgrade_selected.emit(id)
