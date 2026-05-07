## UpgradesMenu.gd
## Menu for purchasing permanent meta-upgrades with gold.
extends Control

signal back_pressed

const COLOR_CYAN := Color("#00FFFF")
const COLOR_GOLD := Color("#FFAC1C")
const COLOR_WHITE := Color("#F0F8FF")
const COLOR_GREEN := Color("#39FF14")
const COLOR_GRAY := Color(0.4, 0.5, 0.55)

var _upgrade_cards: Array = []
var _gold_label: Label
var _back_btn: Button

const UPGRADES := [
	{"id": "hp_up", "name": "Max HP", "desc": "+10 Max HP per level", "base_cost": 50, "cost_mult": 1.5, "max_level": 10, "icon": "❤️"},
	{"id": "speed_up", "name": "Move Speed", "desc": "+5 Speed per level", "base_cost": 40, "cost_mult": 1.4, "max_level": 10, "icon": "⚡"},
	{"id": "damage_up", "name": "Damage", "desc": "+5% Damage per level", "base_cost": 60, "cost_mult": 1.6, "max_level": 10, "icon": "⚔️"},
	{"id": "exp_up", "name": "EXP Gain", "desc": "+5% XP per level", "base_cost": 45, "cost_mult": 1.4, "max_level": 10, "icon": "🧬"},
	{"id": "armor_up", "name": "Armor", "desc": "+2 Damage reduction per level", "base_cost": 50, "cost_mult": 1.5, "max_level": 10, "icon": "🛡️"},
	{"id": "regen_up", "name": "HP Regen", "desc": "+0.5 HP/sec per level", "base_cost": 70, "cost_mult": 1.7, "max_level": 10, "icon": "💚"},
	{"id": "magnet_up", "name": "Pickup Range", "desc": "+10 Range per level", "base_cost": 35, "cost_mult": 1.3, "max_level": 10, "icon": "🧲"},
	{"id": "luck_up", "name": "Luck", "desc": "+5% Rarity chance per level", "base_cost": 55, "cost_mult": 1.5, "max_level": 10, "icon": "🍀"},
]


func _ready() -> void:
	_build_ui()
	set_process_input(true)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		_on_back_pressed()


func _build_ui() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

	var bg := ColorRect.new()
	bg.color = Color(0.01, 0.01, 0.03, 0.98)
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(bg)

	var main_vbox := VBoxContainer.new()
	main_vbox.set_anchors_preset(Control.PRESET_FULL_RECT)
	main_vbox.add_theme_constant_override("separation", 20)
	add_child(main_vbox)

	var header := HBoxContainer.new()
	header.custom_minimum_size = Vector2(0, 80)
	main_vbox.add_child(header)

	var title := Label.new()
	title.text = "🧬 MUTATIONS"
	title.add_theme_font_size_override("font_size", 42)
	title.modulate = COLOR_CYAN
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	header.add_child(title)

	header.add_child(Control.new())

	_gold_label = Label.new()
	_gold_label.add_theme_font_size_override("font_size", 28)
	_gold_label.modulate = COLOR_GOLD
	header.add_child(_gold_label)

	var scroll := ScrollContainer.new()
	scroll.custom_minimum_size = Vector2(0, 400)
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	main_vbox.add_child(scroll)

	var grid := HBoxContainer.new()
	grid.add_theme_constant_override("separation", 16)
	scroll.add_child(grid)

	for upg in UPGRADES:
		var card := _create_upgrade_card(upg)
		grid.add_child(card)
		_upgrade_cards.append(card)

	var footer := HBoxContainer.new()
	footer.custom_minimum_size = Vector2(0, 80)
	footer.alignment = BoxContainer.ALIGNMENT_CENTER
	main_vbox.add_child(footer)

	_back_btn = Button.new()
	_back_btn.text = "◀  BACK"
	_back_btn.custom_minimum_size = Vector2(200, 60)
	_back_btn.pressed.connect(_on_back_pressed)
	footer.add_child(_back_btn)

	_style_buttons()
	_update_display()


func _create_upgrade_card(upg: Dictionary) -> Control:
	var card := VBoxContainer.new()
	card.custom_minimum_size = Vector2(180, 220)
	card.add_theme_constant_override("separation", 8)

	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.04, 0.04, 0.1, 0.95)
	style.set_corner_radius_all(16)
	style.border_width_left = 2
	style.border_width_top = 2
	style.border_width_right = 2
	style.border_width_bottom = 2
	style.border_color = Color(0.2, 0.3, 0.4, 0.5)
	card.add_theme_stylebox_override("normal", style)

	var icon := Label.new()
	icon.text = upg["icon"]
	icon.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	icon.add_theme_font_size_override("font_size", 36)
	card.add_child(icon)

	var name := Label.new()
	name.text = upg["name"]
	name.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name.add_theme_font_size_override("font_size", 18)
	name.modulate = COLOR_WHITE
	card.add_child(name)

	var desc := Label.new()
	desc.text = upg["desc"]
	desc.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	desc.add_theme_font_size_override("font_size", 12)
	desc.modulate = COLOR_GRAY
	desc.autowrap_mode = TextServer.AUTOWRAP_WORD
	card.add_child(desc)

	var level_lbl := Label.new()
	level_lbl.name = "LevelLabel"
	level_lbl.text = "Lv. 0"
	level_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	level_lbl.add_theme_font_size_override("font_size", 16)
	level_lbl.modulate = COLOR_CYAN
	card.add_child(level_lbl)

	var cost_lbl := Label.new()
	cost_lbl.name = "CostLabel"
	cost_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	cost_lbl.add_theme_font_size_override("font_size", 20)
	cost_lbl.modulate = COLOR_GOLD
	card.add_child(cost_lbl)

	var buy_btn := Button.new()
	buy_btn.text = "BUY"
	buy_btn.custom_minimum_size = Vector2(140, 40)
	buy_btn.pressed.connect(_on_buy_pressed.bind(upg["id"], buy_btn))
	card.add_child(buy_btn)

	var btn_style := StyleBoxFlat.new()
	btn_style.bg_color = Color(0.1, 0.15, 0.2, 0.9)
	btn_style.set_corner_radius_all(10)
	btn_style.border_width_left = 1
	btn_style.border_width_right = 1
	btn_style.border_width_top = 1
	btn_style.border_width_bottom = 1
	btn_style.border_color = COLOR_GOLD.darkened(0.5)

	var btn_hover := btn_style.duplicate()
	btn_hover.border_color = COLOR_GOLD

	var btn_disabled := btn_style.duplicate()
	btn_disabled.bg_color = Color(0.1, 0.1, 0.1, 0.8)
	btn_disabled.border_color = Color(0.3, 0.3, 0.3, 0.5)

	buy_btn.add_theme_stylebox_override("normal", btn_style)
	buy_btn.add_theme_stylebox_override("hover", btn_hover)
	buy_btn.add_theme_stylebox_override("disabled", btn_disabled)
	buy_btn.add_theme_font_size_override("font_size", 18)

	card.set_meta("upgrade_id", upg["id"])
	return card


func _style_buttons() -> void:
	if _back_btn:
		_back_btn.add_theme_font_size_override("font_size", 22)
		_back_btn.custom_minimum_size = Vector2(180, 60)

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

		_back_btn.add_theme_stylebox_override("normal", style)
		_back_btn.add_theme_stylebox_override("hover", hover)


func _update_display() -> void:
	var gold := SaveManager.get_gold()
	_gold_label.text = "💰 %d" % gold

	for card in _upgrade_cards:
		var upg_id: String = card.get_meta("upgrade_id")
		var level := SaveManager.get_meta_level(upg_id)
		var upg := _find_upgrade(upg_id)

		var level_lbl: Label = card.get_node("LevelLabel")
		var cost_lbl: Label = card.get_node("CostLabel")
		var buy_btn: Button = card.get_node_or_null("Button")

		level_lbl.text = "Lv. %d" % level

		if level >= upg["max_level"]:
			cost_lbl.text = "MAX"
			cost_lbl.modulate = COLOR_GREEN
			if buy_btn:
				buy_btn.disabled = true
				buy_btn.text = "MAX"
		else:
			var cost := _calculate_cost(upg, level)
			cost_lbl.text = "💰 %d" % cost
			if gold >= cost:
				cost_lbl.modulate = COLOR_GOLD
				if buy_btn:
					buy_btn.disabled = false
					buy_btn.text = "BUY"
			else:
				cost_lbl.modulate = COLOR_GRAY
				if buy_btn:
					buy_btn.disabled = true
					buy_btn.text = "LOCKED"


func _find_upgrade(id: String) -> Dictionary:
	for upg in UPGRADES:
		if upg["id"] == id:
			return upg
	return {}


func _calculate_cost(upg: Dictionary, current_level: int) -> int:
	var base_cost: int = upg["base_cost"]
	var cost_mult: float = upg["cost_mult"]
	return int(base_cost * pow(cost_mult, current_level))


func _on_buy_pressed(upgrade_id: String, _btn: Button) -> void:
	var upg := _find_upgrade(upgrade_id)
	var level := SaveManager.get_meta_level(upgrade_id)
	var cost := _calculate_cost(upg, level)

	if level >= upg["max_level"]:
		return

	if SaveManager.spend_gold(cost):
		SaveManager.upgrade_meta(upgrade_id)
		_update_display()


func _on_back_pressed() -> void:
	back_pressed.emit()
	queue_free()