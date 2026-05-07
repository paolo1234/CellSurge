## UpgradesMenu.gd
class_name UpgradesMenu
extends Control

signal back_pressed

const COLOR_CYAN := Color(0.0, 0.8, 1.0, 1.0)
const COLOR_BG := Color(0.02, 0.05, 0.1, 1.0)
const COLOR_GOLD := Color("#FFD700")
const COLOR_WHITE := Color("#FFFFFF")
const COLOR_GREEN := Color("#39FF14")
const COLOR_GRAY := Color(0.4, 0.5, 0.55)

var _upgrade_cards: Array = []
var _gold_label: Label

const UPGRADES := [
	{"id": "hp_up", "name": "Max HP", "desc": "+10 Max HP", "base_cost": 50, "cost_mult": 1.5, "max_level": 10, "icon": "❤️"},
	{"id": "speed_up", "name": "Velocità", "desc": "+5 Velocità", "base_cost": 40, "cost_mult": 1.4, "max_level": 10, "icon": "⚡"},
	{"id": "damage_up", "name": "Danno", "desc": "+5% Danno", "base_cost": 60, "cost_mult": 1.6, "max_level": 10, "icon": "⚔️"},
	{"id": "exp_up", "name": "EXP Gain", "desc": "+5% XP", "base_cost": 45, "cost_mult": 1.4, "max_level": 10, "icon": "🧬"},
	{"id": "armor_up", "name": "Armatura", "desc": "+2 Armatura", "base_cost": 50, "cost_mult": 1.5, "max_level": 10, "icon": "🛡️"},
	{"id": "regen_up", "name": "Rigenera HP", "desc": "+0.5 HP/s", "base_cost": 70, "cost_mult": 1.7, "max_level": 10, "icon": "💚"},
	{"id": "magnet_up", "name": "Magnete", "desc": "+10 Raggio", "base_cost": 35, "cost_mult": 1.3, "max_level": 10, "icon": "🧲"},
	{"id": "luck_up", "name": "Fortuna", "desc": "+5% Fortuna", "base_cost": 55, "cost_mult": 1.5, "max_level": 10, "icon": "🍀"},
]

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
	bg.color = COLOR_BG
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
	title.text = "🧬 MUTAZIONI"
	title.add_theme_font_size_override("font_size", 48)
	title.add_theme_color_override("font_color", COLOR_WHITE)
	title.add_theme_color_override("font_outline_color", COLOR_CYAN.darkened(0.3))
	title.add_theme_constant_override("outline_size", 8)
	title.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	top_bar.add_child(title)
	
	spacer = Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	top_bar.add_child(spacer)
	
	_gold_label = Label.new()
	_gold_label.text = "💰 %d" % _get_gold()
	_gold_label.add_theme_font_size_override("font_size", 32)
	_gold_label.add_theme_color_override("font_color", COLOR_GOLD)
	_gold_label.add_theme_color_override("font_outline_color", Color.BLACK)
	_gold_label.add_theme_constant_override("outline_size", 4)
	_style_gold_pill(_gold_label)
	top_bar.add_child(_gold_label)
	
	var grid = GridContainer.new()
	grid.set_anchors_preset(Control.PRESET_FULL_RECT)
	grid.offset_top = 120
	grid.offset_left = 20
	grid.offset_right = -20
	grid.offset_bottom = -20
	grid.columns = 4
	grid.add_theme_constant_override("h_separation", 15)
	grid.add_theme_constant_override("v_separation", 15)
	grid.size_flags_vertical = Control.SIZE_EXPAND_FILL
	grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	add_child(grid)
	
	for upg in UPGRADES:
		var card = _create_card(upg)
		grid.add_child(card)
		_upgrade_cards.append(card)
	
	_update_display()

func _create_card(upg: Dictionary) -> Control:
	var card = PanelContainer.new()
	card.custom_minimum_size = Vector2(200, 180)
	card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	card.size_flags_vertical = Control.SIZE_EXPAND_FILL
	
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.02, 0.04, 0.08, 0.95)
	style.set_corner_radius_all(16)
	style.border_width_left = 2
	style.border_width_right = 2
	style.border_width_top = 2
	style.border_width_bottom = 2
	style.border_color = COLOR_CYAN.darkened(0.4)
	card.add_theme_stylebox_override("panel", style)
	
	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 4)
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	card.add_child(vbox)
	
	var icon = Label.new()
	icon.text = upg["icon"]
	icon.add_theme_font_size_override("font_size", 36)
	icon.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(icon)
	
	var name = Label.new()
	name.text = upg["name"]
	name.add_theme_font_size_override("font_size", 18)
	name.add_theme_color_override("font_color", COLOR_WHITE)
	name.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(name)
	
	var desc = Label.new()
	desc.text = upg["desc"]
	desc.add_theme_font_size_override("font_size", 12)
	desc.add_theme_color_override("font_color", COLOR_GRAY)
	desc.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(desc)
	
	var level_lbl = Label.new()
	level_lbl.name = "LevelLabel"
	level_lbl.add_theme_font_size_override("font_size", 14)
	level_lbl.add_theme_color_override("font_color", COLOR_CYAN)
	level_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(level_lbl)
	
	var cost_lbl = Label.new()
	cost_lbl.name = "CostLabel"
	cost_lbl.add_theme_font_size_override("font_size", 18)
	cost_lbl.add_theme_color_override("font_color", COLOR_GOLD)
	cost_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(cost_lbl)
	
	var btn = Button.new()
	btn.name = "BuyButton"
	btn.custom_minimum_size = Vector2(120, 40)
	btn.pressed.connect(_on_buy_pressed.bind(upg["id"], btn))
	_style_buy_button(btn)
	vbox.add_child(btn)
	
	card.set_meta("upgrade_id", upg["id"])
	return card

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

func _style_buy_button(btn: Button) -> void:
	btn.add_theme_font_size_override("font_size", 16)
	var style = StyleBoxFlat.new()
	style.bg_color = COLOR_GOLD.darkened(0.4)
	style.set_corner_radius_all(12)
	style.border_width_left = 2
	style.border_width_right = 2
	style.border_width_top = 2
	style.border_width_bottom = 2
	style.border_color = COLOR_GOLD
	btn.add_theme_stylebox_override("normal", style)
	var disabled = StyleBoxFlat.new()
	disabled.bg_color = Color(0.15, 0.15, 0.15, 0.9)
	disabled.border_color = Color(0.3, 0.3, 0.3, 0.5)
	btn.add_theme_stylebox_override("disabled", disabled)

func _style_gold_pill(lbl: Label) -> void:
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.0, 0.0, 0.0, 0.7)
	style.set_corner_radius_all(16)
	style.border_width_left = 2
	style.border_width_right = 2
	style.border_width_top = 2
	style.border_width_bottom = 2
	style.border_color = COLOR_GOLD.darkened(0.5)
	style.content_margin_left = 16
	style.content_margin_right = 16
	style.content_margin_top = 8
	style.content_margin_bottom = 8
	lbl.add_theme_stylebox_override("normal", style)

func _get_gold() -> int:
	if has_node("/root/SaveManager"):
		return get_node("/root/SaveManager").get_gold()
	return 0

func _get_meta_level(id: String) -> int:
	if has_node("/root/SaveManager"):
		return get_node("/root/SaveManager").get_meta_level(id)
	return 0

func _spend_gold(amount: int) -> bool:
	if has_node("/root/SaveManager"):
		return get_node("/root/SaveManager").spend_gold(amount)
	return false

func _upgrade_meta(id: String) -> void:
	if has_node("/root/SaveManager"):
		get_node("/root/SaveManager").upgrade_meta(id)

func _update_display() -> void:
	var gold = _get_gold()
	_gold_label.text = "💰 %d" % gold
	
	for card in _upgrade_cards:
		var id: String = card.get_meta("upgrade_id")
		var level = _get_meta_level(id)
		var upg = _find_upgrade(id)
		var vbox: VBoxContainer = card.get_child(0)
		var level_lbl: Label = vbox.get_node("LevelLabel")
		var cost_lbl: Label = vbox.get_node("CostLabel")
		var buy_btn: Button = vbox.get_node("BuyButton")
		
		level_lbl.text = "Lv. %d/%d" % [level, upg["max_level"]]
		
		if level >= upg["max_level"]:
			cost_lbl.text = "MAX"
			cost_lbl.add_theme_color_override("font_color", COLOR_GREEN)
			buy_btn.disabled = true
			buy_btn.text = "MAX"
		else:
			var cost = int(upg["base_cost"] * pow(upg["cost_mult"], level))
			cost_lbl.text = "💰 %d" % cost
			if gold >= cost:
				cost_lbl.add_theme_color_override("font_color", COLOR_GOLD)
				buy_btn.disabled = false
				buy_btn.text = "COMPRA"
			else:
				cost_lbl.add_theme_color_override("font_color", COLOR_GRAY)
				buy_btn.disabled = true
				buy_btn.text = "BLOCCATO"

func _find_upgrade(id: String) -> Dictionary:
	for upg in UPGRADES:
		if upg["id"] == id:
			return upg
	return {}

func _on_buy_pressed(id: String, btn: Button) -> void:
	var upg = _find_upgrade(id)
	var level = _get_meta_level(id)
	var cost = int(upg["base_cost"] * pow(upg["cost_mult"], level))
	
	if level >= upg["max_level"]:
		return
	if _spend_gold(cost):
		_upgrade_meta(id)
		_update_display()

func _on_back_pressed() -> void:
	back_pressed.emit()
	queue_free()