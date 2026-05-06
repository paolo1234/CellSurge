## LevelUpScreen.gd
## Pauses the game and presents upgrade choices to the player.
## Bioluminescenza theme aligned with DESIGN_UI.md palette.
extends CanvasLayer

const COLOR_BG := Color(0.01, 0.01, 0.03, 0.92)
const COLOR_PANEL := Color(0.03, 0.03, 0.08, 0.95)
const COLOR_CYAN := Color("#00FFFF")
const COLOR_GOLD := Color("#FFAC1C")
const COLOR_WHITE := Color("#F0F8FF")
const COLOR_RARE := Color(0.3, 0.5, 1.0)
const COLOR_EPIC := Color(0.6, 0.3, 0.9)

var _choice_buttons: Array = []
var _choices: Array[Dictionary] = []


func _ready() -> void:
	_build_ui()
	visible = false


func _build_ui() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

	var overlay := ColorRect.new()
	overlay.color = COLOR_BG
	overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(overlay)

	var main_vbox := VBoxContainer.new()
	main_vbox.set_anchors_preset(Control.PRESET_FULL_RECT)
	main_vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	main_vbox.add_theme_constant_override("separation", 32)
	add_child(main_vbox)

	var title := Label.new()
	title.text = "⚡ LEVEL UP!"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 56)
	title.modulate = COLOR_GOLD
	main_vbox.add_child(title)

	var subtitle := Label.new()
	subtitle.text = "Choose a mutation"
	subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	subtitle.add_theme_font_size_override("font_size", 24)
	subtitle.modulate = Color(0.4, 0.5, 0.55)
	main_vbox.add_child(subtitle)

	var cards_hbox := HBoxContainer.new()
	cards_hbox.add_theme_constant_override("separation", 24)
	cards_hbox.alignment = BoxContainer.ALIGNMENT_CENTER
	main_vbox.add_child(cards_hbox)

	for i in 3:
		var card := _create_card(i)
		cards_hbox.add_child(card)
		_choice_buttons.append(card)
		var idx := i
		card.pressed.connect(_on_choice_pressed.bind(idx))


func _create_card(_index: int) -> Button:
	var card := Button.new()
	card.custom_minimum_size = Vector2(200, 260)
	card.process_mode = Node.PROCESS_MODE_ALWAYS

	var style := StyleBoxFlat.new()
	style.bg_color = COLOR_PANEL
	style.set_corner_radius_all(16)
	style.border_width_left = 2
	style.border_width_top = 2
	style.border_width_right = 2
	style.border_width_bottom = 2
	style.border_color = Color(0.0, 0.3, 0.3, 0.5)

	var style_hover := style.duplicate()
	style_hover.border_color = COLOR_CYAN
	style_hover.bg_color = Color(0.04, 0.06, 0.12, 0.98)

	card.add_theme_stylebox_override("normal", style)
	card.add_theme_stylebox_override("hover", style_hover)
	card.add_theme_stylebox_override("pressed", style)
	card.add_theme_stylebox_override("disabled", style)
	card.add_theme_stylebox_override("focus", StyleBoxEmpty.new())

	return card


func show_choices(choices: Array[Dictionary], _level: int) -> void:
	_choices = choices

	if choices.is_empty():
		return

	for i in range(3):
		var card = _choice_buttons[i]

		# Clear existing children
		for c in card.get_children():
			c.queue_free()

		if i < choices.size():
			var up = choices[i]
			var data = up.get("data", {})
			var upg_name = data.get("name", "Unknown")
			var desc = data.get("desc", "")
			var rarity = data.get("rarity", "common")

			var card_content = VBoxContainer.new()
			card_content.add_theme_constant_override("separation", 14)
			card_content.set_anchors_preset(Control.PRESET_FULL_RECT)
			card_content.offset_left = 14
			card_content.offset_top = 14
			card_content.offset_right = -14
			card_content.offset_bottom = -14
			card.add_child(card_content)

			var rarity_label = Label.new()
			rarity_label.text = rarity.to_upper()
			rarity_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			rarity_label.add_theme_font_size_override("font_size", 14)
			rarity_label.modulate = _get_rarity_color(rarity)
			rarity_label.custom_minimum_size = Vector2(0, 28)
			card_content.add_child(rarity_label)

			var name_label = Label.new()
			name_label.text = upg_name
			name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			name_label.add_theme_font_size_override("font_size", 22)
			name_label.modulate = COLOR_WHITE
			name_label.autowrap_mode = TextServer.AUTOWRAP_WORD
			name_label.custom_minimum_size = Vector2(0, 60)
			card_content.add_child(name_label)

			var desc_label = Label.new()
			desc_label.text = desc
			desc_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			desc_label.add_theme_font_size_override("font_size", 16)
			desc_label.modulate = Color(0.5, 0.6, 0.65)
			desc_label.autowrap_mode = TextServer.AUTOWRAP_WORD
			desc_label.custom_minimum_size = Vector2(0, 100)
			card_content.add_child(desc_label)

			card.visible = true
			card.disabled = false
		else:
			card.visible = false

	visible = true
	get_tree().paused = true


func _get_rarity_color(rarity: String) -> Color:
	match rarity:
		"rare": return COLOR_RARE
		"epic": return COLOR_EPIC
		_: return Color(0.4, 0.5, 0.55)


func _on_choice_pressed(index: int) -> void:
	get_tree().paused = false
	visible = false
	if index < _choices.size():
		var upgrade_id = _choices[index].get("id", "")
		if upgrade_id != "":
			EventBus.upgrade_selected.emit(upgrade_id)
