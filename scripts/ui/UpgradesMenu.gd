## UpgradesMenu.gd
## Full-screen meta-upgrades shop with 2-column grid and scroll.
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
	# Top bar
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
	back_btn.custom_minimum_size = Vector2(180, 70)
	back_btn.pressed.connect(_on_back_pressed)
	_style_nav_button(back_btn)
	top_bar.add_child(back_btn)
	var spacer = Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	top_bar.add_child(spacer)
	var title = Label.new()
	title.text = "🧬 MUTAZIONI"
	title.add_theme_font_size_override("font_size", 42)
	title.add_theme_color_override("font_color", COLOR_WHITE)
	title.add_theme_color_override("font_outline_color", COLOR_CYAN.darkened(0.3))
	title.add_theme_constant_override("outline_size", 6)
	title.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	top_bar.add_child(title)
	var spacer2 = Control.new()
	spacer2.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	top_bar.add_child(spacer2)
	_gold_label = Label.new()
	_gold_label.text = "💰 %d" % SaveManager.get_gold()
	_gold_label.add_theme_font_size_override("font_size", 32)
	_gold_label.add_theme_color_override("font_color", COLOR_GOLD)
	_gold_label.add_theme_color_override("font_outline_color", Color.BLACK)
	_gold_label.add_theme_constant_override("outline_size", 4)
	_style_gold_pill(_gold_label)
	top_bar.add_child(_gold_label)
	# ScrollContainer with 2-column grid
	var scroll := ScrollContainer.new()
	scroll.set_anchors_preset(Control.PRESET_FULL_RECT)
	scroll.offset_top = 130
	scroll.offset_left = 20
	scroll.offset_right = -20
	scroll.offset_bottom = -20
	scroll.custom_minimum_size.y = 400
	add_child(scroll)
	var grid = GridContainer.new()
	grid.columns = 2
	grid.add_theme_constant_override("h_separation", 16)
	grid.add_theme_constant_override("v_separation", 16)
	grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(grid)
	for upg in UPGRADES:
		var card = _create_card(upg)
		grid.add_child(card)
		_upgrade_cards.append(card)
	_update_display()

func _create_card(upg: Dictionary) -> Control:
	var card = PanelContainer.new()
	card.custom_minimum_size = Vector2(0, 220)
	card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.02, 0.04, 0.08, 0.95)
	style.set_corner_radius_all(16)
	style.set_border_width_all(2)
	style.border_color = COLOR_CYAN.darkened(0.4)
	style.content_margin_left = 12
	style.content_margin_right = 12
	style.content_margin_top = 12
	style.content_margin_bottom = 12
	card.add_theme_stylebox_override("panel", style)
	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 6)
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	card.add_child(vbox)
	var icon = Label.new()
	icon.text = upg["icon"]
	icon.add_theme_font_size_override("font_size", 40)
	icon.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(icon)
	var name_lbl = Label.new()
	name_lbl.text = upg["name"]
	name_lbl.add_theme_font_size_override("font_size", 22)
	name_lbl.add_theme_color_override("font_color", COLOR_WHITE)
	name_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(name_lbl)
	var desc = Label.new()
	desc.text = upg["desc"]
	desc.add_theme_font_size_override("font_size", 16)
	desc.add_theme_color_override("font_color", COLOR_GRAY)
	desc.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(desc)
	# Level progress bar
	var bar_bg := ProgressBar.new()
	bar_bg.name = "ProgressBar"
	bar_bg.show_percentage = false
	bar_bg.max_value = upg["max_level"]
	bar_bg.custom_minimum_size = Vector2(0, 10)
	var bg_s := StyleBoxFlat.new()
	bg_s.bg_color = Color(0.1, 0.1, 0.15, 0.8)
	bg_s.set_corner_radius_all(5)
	bar_bg.add_theme_stylebox_override("background", bg_s)
	var fill_s := StyleBoxFlat.new()
	fill_s.bg_color = COLOR_CYAN
	fill_s.set_corner_radius_all(5)
	bar_bg.add_theme_stylebox_override("fill", fill_s)
	vbox.add_child(bar_bg)
	var level_lbl = Label.new()
	level_lbl.name = "LevelLabel"
	level_lbl.add_theme_font_size_override("font_size", 16)
	level_lbl.add_theme_color_override("font_color", COLOR_CYAN)
	level_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(level_lbl)
	var cost_lbl = Label.new()
	cost_lbl.name = "CostLabel"
	cost_lbl.add_theme_font_size_override("font_size", 20)
	cost_lbl.add_theme_color_override("font_color", COLOR_GOLD)
	cost_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(cost_lbl)
	var btn = Button.new()
	btn.name = "BuyButton"
	btn.custom_minimum_size = Vector2(0, 50)
	btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	btn.pressed.connect(_on_buy_pressed.bind(upg["id"], btn))
	_style_buy_button(btn)
	vbox.add_child(btn)
	card.set_meta("upgrade_id", upg["id"])
	return card

func _style_nav_button(btn: Button) -> void:
	btn.add_theme_font_size_override("font_size", 24)
	btn.add_theme_color_override("font_color", COLOR_WHITE)
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.0, 0.15, 0.25, 0.95)
	style.set_corner_radius_all(20)
	style.set_border_width_all(3)
	style.border_color = COLOR_CYAN
	btn.add_theme_stylebox_override("normal", style)
	btn.add_theme_stylebox_override("hover", style)

func _style_buy_button(btn: Button) -> void:
	btn.add_theme_font_size_override("font_size", 20)
	btn.add_theme_color_override("font_color", Color(0.05, 0.05, 0.05))
	var style = StyleBoxFlat.new()
	style.bg_color = COLOR_GOLD
	style.set_corner_radius_all(14)
	btn.add_theme_stylebox_override("normal", style)
	var hover = style.duplicate() as StyleBoxFlat
	hover.bg_color = COLOR_GOLD.lightened(0.1)
	btn.add_theme_stylebox_override("hover", hover)
	var disabled = StyleBoxFlat.new()
	disabled.bg_color = Color(0.15, 0.15, 0.15, 0.9)
	disabled.set_corner_radius_all(14)
	disabled.border_color = Color(0.3, 0.3, 0.3, 0.5)
	disabled.set_border_width_all(2)
	btn.add_theme_stylebox_override("disabled", disabled)

func _style_gold_pill(lbl: Label) -> void:
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0, 0, 0, 0.7)
	style.set_corner_radius_all(16)
	style.set_border_width_all(2)
	style.border_color = COLOR_GOLD.darkened(0.5)
	style.content_margin_left = 16
	style.content_margin_right = 16
	style.content_margin_top = 8
	style.content_margin_bottom = 8
	lbl.add_theme_stylebox_override("normal", style)

func _update_display() -> void:
	var gold = SaveManager.get_gold()
	_gold_label.text = "💰 %d" % gold
	for card in _upgrade_cards:
		var id: String = card.get_meta("upgrade_id")
		var level = SaveManager.get_meta_level(id)
		var upg = _find_upgrade(id)
		var vbox: VBoxContainer = card.get_child(0)
		var progress: ProgressBar = vbox.get_node("ProgressBar")
		var level_lbl: Label = vbox.get_node("LevelLabel")
		var cost_lbl: Label = vbox.get_node("CostLabel")
		var buy_btn: Button = vbox.get_node("BuyButton")
		progress.value = level
		level_lbl.text = "Lv. %d/%d" % [level, upg["max_level"]]
		if level >= upg["max_level"]:
			cost_lbl.text = "MAX"
			cost_lbl.add_theme_color_override("font_color", COLOR_GREEN)
			buy_btn.disabled = true
			buy_btn.text = "✅ MAX"
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

func _on_buy_pressed(id: String, _btn: Button) -> void:
	var upg = _find_upgrade(id)
	var level = SaveManager.get_meta_level(id)
	var cost = int(upg["base_cost"] * pow(upg["cost_mult"], level))
	if level >= upg["max_level"]:
		return
	if SaveManager.buy_meta_upgrade(id, cost):
		AudioManager.play_pickup()
		_update_display()

func _on_back_pressed() -> void:
	back_pressed.emit()
	queue_free()