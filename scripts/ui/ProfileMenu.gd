## ProfileMenu.gd
class_name ProfileMenu
extends Control

signal back_pressed

const COLOR_CYAN := Color(0.0, 0.8, 1.0, 1.0)
const COLOR_WHITE := Color("#FFFFFF")
const COLOR_GOLD := Color("#FFD700")
const COLOR_GREEN := Color("#39FF14")
const COLOR_GRAY := Color(0.4, 0.5, 0.55)

const UPGRADES := {
	"hp_up": {"name": "Max HP", "icon": "❤️", "per_level": "+10 HP"},
	"speed_up": {"name": "Velocità", "icon": "⚡", "per_level": "+5 Speed"},
	"damage_up": {"name": "Danno", "icon": "⚔️", "per_level": "+5% DMG"},
	"exp_up": {"name": "EXP Gain", "icon": "🧬", "per_level": "+5% XP"},
	"armor_up": {"name": "Armatura", "icon": "🛡️", "per_level": "+2 ARM"},
	"regen_up": {"name": "Rigenera", "icon": "💚", "per_level": "+0.5 HP/s"},
	"magnet_up": {"name": "Magnete", "icon": "🧲", "per_level": "+10 Range"},
	"luck_up": {"name": "Fortuna", "icon": "🍀", "per_level": "+5% Rarity"},
}

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
	title.text = "👤 PROFILO"
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
	content.add_theme_constant_override("separation", 16)
	content.size_flags_vertical = Control.SIZE_EXPAND_FILL
	content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	content.alignment = BoxContainer.ALIGNMENT_CENTER
	add_child(content)
	
	var player_name = Label.new()
	player_name.text = "CELL LEUKOCYTE"
	player_name.add_theme_font_size_override("font_size", 36)
	player_name.add_theme_color_override("font_color", COLOR_WHITE)
	content.add_child(player_name)
	
	var level = Label.new()
	level.text = "Livello %d" % _get_player_level()
	level.add_theme_font_size_override("font_size", 24)
	level.add_theme_color_override("font_color", COLOR_GOLD)
	content.add_child(level)
	
	var runs = Label.new()
	runs.text = "Partite: %d" % _get_total_runs()
	runs.add_theme_font_size_override("font_size", 20)
	runs.add_theme_color_override("font_color", COLOR_GRAY)
	content.add_child(runs)
	
	var divider = ColorRect.new()
	divider.custom_minimum_size = Vector2(400, 2)
	divider.color = Color(0.2, 0.3, 0.4, 0.5)
	content.add_child(divider)
	
	var upgrades_title = Label.new()
	upgrades_title.text = "MUTAZIONI ATTIVE"
	upgrades_title.add_theme_font_size_override("font_size", 28)
	upgrades_title.add_theme_color_override("font_color", COLOR_CYAN)
	content.add_child(upgrades_title)
	
	var grid = GridContainer.new()
	grid.columns = 4
	grid.add_theme_constant_override("h_separation", 10)
	grid.add_theme_constant_override("v_separation", 10)
	grid.size_flags_vertical = Control.SIZE_EXPAND_FILL
	grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	content.add_child(grid)
	
	for id in UPGRADES.keys():
		var info = UPGRADES[id]
		var lvl = _get_upgrade_level(id)
		var card = _create_card(id, info, lvl)
		grid.add_child(card)

func _create_card(id: String, info: Dictionary, level: int) -> Control:
	var card = PanelContainer.new()
	card.custom_minimum_size = Vector2(120, 100)
	card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	card.size_flags_vertical = Control.SIZE_EXPAND_FILL
	
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.03, 0.05, 0.1, 0.95)
	style.set_corner_radius_all(12)
	if level > 0:
		style.border_width_left = 2
		style.border_width_right = 2
		style.border_width_top = 2
		style.border_width_bottom = 2
		style.border_color = COLOR_CYAN.darkened(0.3)
	card.add_theme_stylebox_override("panel", style)
	
	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 2)
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	card.add_child(vbox)
	
	var icon = Label.new()
	icon.text = info["icon"]
	icon.add_theme_font_size_override("font_size", 24)
	vbox.add_child(icon)
	
	var name = Label.new()
	name.text = info["name"]
	name.add_theme_font_size_override("font_size", 12)
	name.add_theme_color_override("font_color", COLOR_WHITE)
	vbox.add_child(name)
	
	var lvl_lbl = Label.new()
	if level > 0:
		lvl_lbl.text = "Lv.%d" % level
		lvl_lbl.add_theme_color_override("font_color", COLOR_GREEN)
	else:
		lvl_lbl.text = "LOCKED"
		lvl_lbl.add_theme_color_override("font_color", COLOR_GRAY)
	lvl_lbl.add_theme_font_size_override("font_size", 12)
	vbox.add_child(lvl_lbl)
	
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

func _get_upgrade_level(id: String) -> int:
	if has_node("/root/SaveManager"):
		return get_node("/root/SaveManager").get_meta_level(id)
	return 0

func _get_total_runs() -> int:
	if has_node("/root/SaveManager"):
		return get_node("/root/SaveManager").data.get("total_runs", 0)
	return 0

func _get_player_level() -> int:
	return min(_get_total_runs() + 1, 50)

func _on_back_pressed() -> void:
	back_pressed.emit()
	queue_free()