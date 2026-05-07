## ProfileMenu.gd
## Player profile screen showing stats, active upgrades and info.
extends Control

signal back_pressed

const COLOR_CYAN := Color("#00FFFF")
const COLOR_CYAN_GLOW := Color(0.0, 1.0, 1.0, 0.6)
const COLOR_GOLD := Color("#FFAC1C")
const COLOR_WHITE := Color("#F0F8FF")
const COLOR_GREEN := Color("#39FF14")
const COLOR_GRAY := Color(0.4, 0.5, 0.55)

var _back_btn: Button

const UPGRADES_INFO := {
	"hp_up": {"name": "Max HP", "icon": "❤️", "per_level": "+10 HP"},
	"speed_up": {"name": "Move Speed", "icon": "⚡", "per_level": "+5 Speed"},
	"damage_up": {"name": "Damage", "icon": "⚔️", "per_level": "+5% DMG"},
	"exp_up": {"name": "EXP Gain", "icon": "🧬", "per_level": "+5% XP"},
	"armor_up": {"name": "Armor", "icon": "🛡️", "per_level": "+2 ARM"},
	"regen_up": {"name": "HP Regen", "icon": "💚", "per_level": "+0.5 HP/s"},
	"magnet_up": {"name": "Pickup Range", "icon": "🧲", "per_level": "+10 Range"},
	"luck_up": {"name": "Luck", "icon": "🍀", "per_level": "+5% Rarity"},
}


func _ready() -> void:
	_build_ui()
	set_process_input(true)


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
	main_vbox.custom_minimum_size = Vector2(700, 650)
	main_vbox.add_theme_constant_override("separation", 20)
	center.add_child(main_vbox)

	var title := Label.new()
	title.text = "👤 PROFILO"
	title.add_theme_font_size_override("font_size", 48)
	title.modulate = COLOR_CYAN
	main_vbox.add_child(title)

	var stats_container := VBoxContainer.new()
	stats_container.add_theme_constant_override("separation", 16)
	main_vbox.add_child(stats_container)

	var player_name := Label.new()
	player_name.text = "CELL LEUKOCYTE"
	player_name.add_theme_font_size_override("font_size", 32)
	player_name.modulate = COLOR_WHITE
	player_name.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	stats_container.add_child(player_name)

	var level_label := Label.new()
	level_label.text = "Livello %d" % _get_player_level()
	level_label.add_theme_font_size_override("font_size", 22)
	level_label.modulate = COLOR_GOLD
	level_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	stats_container.add_child(level_label)

	var runs_label := Label.new()
	runs_label.text = "Partite giocate: %d" % _get_total_runs()
	runs_label.add_theme_font_size_override("font_size", 18)
	runs_label.modulate = COLOR_GRAY
	runs_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	stats_container.add_child(runs_label)

	var divider := ColorRect.new()
	divider.custom_minimum_size = Vector2(500, 2)
	divider.color = Color(0.2, 0.3, 0.4, 0.5)
	main_vbox.add_child(divider)

	var upgrades_label := Label.new()
	upgrades_label.text = "MUTAZIONI ATTIVE"
	upgrades_label.add_theme_font_size_override("font_size", 28)
	upgrades_label.modulate = COLOR_CYAN
	upgrades_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	main_vbox.add_child(upgrades_label)

	var upgrades_grid := GridContainer.new()
	upgrades_grid.columns = 4
	upgrades_grid.add_theme_constant_override("h_separation", 10)
	upgrades_grid.add_theme_constant_override("v_separation", 10)
	main_vbox.add_child(upgrades_grid)

	for upg_id in UPGRADES_INFO.keys():
		var upg_info = UPGRADES_INFO[upg_id]
		var level = _get_upgrade_level(upg_id)
		var card := _create_upgrade_card(upg_id, upg_info, level)
		upgrades_grid.add_child(card)

	var spacer := Control.new()
	spacer.custom_minimum_size = Vector2(0, 20)
	main_vbox.add_child(spacer)

	var footer := HBoxContainer.new()
	footer.alignment = BoxContainer.ALIGNMENT_CENTER
	main_vbox.add_child(footer)

	_back_btn = Button.new()
	_back_btn.text = "◀  INDIETRO"
	_back_btn.custom_minimum_size = Vector2(200, 60)
	_back_btn.pressed.connect(_on_back_pressed)
	footer.add_child(_back_btn)

	_style_button(_back_btn)


func _create_upgrade_card(upg_id: String, upg_info: Dictionary, level: int) -> Control:
	var card := VBoxContainer.new()
	card.custom_minimum_size = Vector2(150, 100)

	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.04, 0.04, 0.1, 0.95)
	style.set_corner_radius_all(12)
	if level > 0:
		style.border_width_left = 2
		style.border_width_right = 2
		style.border_width_top = 2
		style.border_width_bottom = 2
		style.border_color = COLOR_CYAN.darkened(0.3)
	card.add_theme_stylebox_override("normal", style)

	var icon := Label.new()
	icon.text = upg_info["icon"]
	icon.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	icon.add_theme_font_size_override("font_size", 28)
	card.add_child(icon)

	var name_lbl := Label.new()
	name_lbl.text = upg_info["name"]
	name_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_lbl.add_theme_font_size_override("font_size", 14)
	name_lbl.modulate = COLOR_WHITE
	card.add_child(name_lbl)

	var level_lbl := Label.new()
	if level > 0:
		level_lbl.text = "Lv. %d" % level
		level_lbl.modulate = COLOR_GREEN
	else:
		level_lbl.text = "LOCKED"
		level_lbl.modulate = COLOR_GRAY
	level_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	level_lbl.add_theme_font_size_override("font_size", 16)
	card.add_child(level_lbl)

	var effect_lbl := Label.new()
	effect_lbl.text = upg_info["per_level"]
	effect_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	effect_lbl.add_theme_font_size_override("font_size", 11)
	effect_lbl.modulate = COLOR_GRAY
	card.add_child(effect_lbl)

	return card


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


func _get_upgrade_level(id: String) -> int:
	if has_node("/root/SaveManager"):
		return get_node("/root/SaveManager").get_meta_level(id)
	return 0


func _get_total_runs() -> int:
	if has_node("/root/SaveManager"):
		return get_node("/root/SaveManager").data.get("total_runs", 0)
	return 0


func _get_player_level() -> int:
	var total_runs = _get_total_runs()
	return min(total_runs + 1, 50)


func _on_back_pressed() -> void:
	back_pressed.emit()
	queue_free()