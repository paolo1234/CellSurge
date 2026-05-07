## UpgradesMenu.gd
## Menu for purchasing permanent meta-upgrades with gold (Mobile Premium).
extends Control

signal back_pressed

const COLOR_CYAN := Color(0.0, 0.8, 1.0, 1.0)
const COLOR_CYAN_GLOW := Color(0.0, 1.0, 1.0, 0.6)
const COLOR_BG := Color(0.02, 0.05, 0.1, 0.98) # Fondo abissale
const COLOR_GOLD := Color("#FFD700")
const COLOR_WHITE := Color("#FFFFFF")
const COLOR_GREEN := Color("#39FF14")
const COLOR_GRAY := Color(0.4, 0.5, 0.55)

var _upgrade_cards: Array = []
var _gold_label: Label
var _back_btn: Button
var _grid: GridContainer

const UPGRADES := [
	{"id": "hp_up", "name": "Max HP", "desc": "+10 Max HP / livello", "base_cost": 50, "cost_mult": 1.5, "max_level": 10, "icon": "❤️"},
	{"id": "speed_up", "name": "Velocità", "desc": "+5 Velocità / livello", "base_cost": 40, "cost_mult": 1.4, "max_level": 10, "icon": "⚡"},
	{"id": "damage_up", "name": "Danno", "desc": "+5% Danno / livello", "base_cost": 60, "cost_mult": 1.6, "max_level": 10, "icon": "⚔️"},
	{"id": "exp_up", "name": "EXP Gain", "desc": "+5% XP / livello", "base_cost": 45, "cost_mult": 1.4, "max_level": 10, "icon": "🧬"},
	{"id": "armor_up", "name": "Armatura", "desc": "+2 Riduzione / livello", "base_cost": 50, "cost_mult": 1.5, "max_level": 10, "icon": "🛡️"},
	{"id": "regen_up", "name": "Rigenera HP", "desc": "+0.5 HP/sec / livello", "base_cost": 70, "cost_mult": 1.7, "max_level": 10, "icon": "💚"},
	{"id": "magnet_up", "name": "Magnete", "desc": "+10 Raggio / livello", "base_cost": 35, "cost_mult": 1.3, "max_level": 10, "icon": "🧲"},
	{"id": "luck_up", "name": "Fortuna", "desc": "+5% Rarità / livello", "base_cost": 55, "cost_mult": 1.5, "max_level": 10, "icon": "🍀"},
]

func _ready() -> void:
	_build_ui()
	set_process_input(true)
	_play_entrance_animation()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		_on_back_pressed()


func _get_save_manager():
	if has_node("/root/SaveManager"):
		return get_node("/root/SaveManager")
	return null


func _get_gold() -> int:
	var sm = _get_save_manager()
	if sm: return sm.get_gold()
	return 0


func _get_meta_level(id: String) -> int:
	var sm = _get_save_manager()
	if sm: return sm.get_meta_level(id)
	return 0


func _spend_gold(amount: int) -> bool:
	var sm = _get_save_manager()
	if sm: return sm.spend_gold(amount)
	return false


func _upgrade_meta(id: String) -> void:
	var sm = _get_save_manager()
	if sm: sm.upgrade_meta(id)


func _build_ui() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	set_anchors_preset(Control.PRESET_FULL_RECT)

	# 1. Sfondo scuro
	var bg := ColorRect.new()
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.color = COLOR_BG
	add_child(bg)

	# 2. VBox Principale che occupa tutto lo schermo
	var main_vbox := VBoxContainer.new()
	main_vbox.set_anchors_preset(Control.PRESET_FULL_RECT)
	main_vbox.add_theme_constant_override("separation", 20)
	main_vbox.add_theme_constant_override("margin_left", 30)
	main_vbox.add_theme_constant_override("margin_right", 30)
	main_vbox.add_theme_constant_override("margin_top", 40)
	main_vbox.add_theme_constant_override("margin_bottom", 40)
	add_child(main_vbox)

	# --- HEADER ---
	var header := HBoxContainer.new()
	header.custom_minimum_size = Vector2(0, 80)
	main_vbox.add_child(header)

	var title := Label.new()
	title.text = "🧬 MUTAZIONI"
	title.add_theme_font_size_override("font_size", 54)
	title.add_theme_color_override("font_color", COLOR_WHITE)
	title.add_theme_color_override("font_outline_color", COLOR_CYAN.darkened(0.3))
	title.add_theme_constant_override("outline_size", 8)
	title.add_theme_color_override("font_shadow_color", COLOR_CYAN_GLOW)
	title.add_theme_constant_override("shadow_outline_size", 20)
	header.add_child(title)

	# Spaziatore per spingere l'oro a destra
	var spacer := Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(spacer)

	_gold_label = Label.new()
	_style_gold_pill(_gold_label)
	header.add_child(_gold_label)

	# --- SCROLL CONTAINER ---
	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL # Prende tutto lo spazio centrale
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	main_vbox.add_child(scroll)

	# Modificato in GridContainer per mobile! (2 colonne)
	_grid = GridContainer.new()
	_grid.columns = 2
	_grid.add_theme_constant_override("h_separation", 24)
	_grid.add_theme_constant_override("v_separation", 24)
	_grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_grid.alignment = BoxContainer.ALIGNMENT_CENTER
	scroll.add_child(_grid)

	for upg in UPGRADES:
		var card := _create_upgrade_card(upg)
		_grid.add_child(card)
		_upgrade_cards.append(card)

	# --- FOOTER ---
	var footer := HBoxContainer.new()
	footer.custom_minimum_size = Vector2(0, 100)
	footer.alignment = BoxContainer.ALIGNMENT_CENTER
	main_vbox.add_child(footer)

	_back_btn = Button.new()
	_back_btn.text = "◀ INDIETRO"
	_back_btn.pressed.connect(_on_back_pressed)
	_setup_touch_animations(_back_btn)
	footer.add_child(_back_btn)

	_style_bottom_button()
	_update_display()

func _create_upgrade_card(upg: Dictionary) -> Control:
	var card := VBoxContainer.new()
	card.custom_minimum_size = Vector2(220, 280) # Più grandi per le dita
	card.add_theme_constant_override("separation", 8)
	card.alignment = BoxContainer.ALIGNMENT_CENTER

	# Stile della carta al Neon
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.02, 0.04, 0.08, 0.85)
	style.set_corner_radius_all(24)
	style.border_width_all = 3
	style.border_color = COLOR_CYAN.darkened(0.5)
	style.shadow_color = COLOR_CYAN * Color(1, 1, 1, 0.15)
	style.shadow_size = 15
	card.add_theme_stylebox_override("panel", style)

	var icon := Label.new()
	icon.text = upg["icon"]
	icon.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	icon.add_theme_font_size_override("font_size", 48)
	card.add_child(icon)

	var name_lbl := Label.new()
	name_lbl.text = upg["name"]
	name_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_lbl.add_theme_font_size_override("font_size", 22)
	name_lbl.add_theme_color_override("font_color", COLOR_WHITE)
	name_lbl.add_theme_color_override("font_outline_color", Color.BLACK)
	name_lbl.add_theme_constant_override("outline_size", 4)
	card.add_child(name_lbl)

	var desc := Label.new()
	desc.text = upg["desc"]
	desc.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	desc.add_theme_font_size_override("font_size", 14)
	desc.add_theme_color_override("font_color", COLOR_GRAY)
	desc.autowrap_mode = TextServer.AUTOWRAP_WORD
	desc.custom_minimum_size.y = 40
	card.add_child(desc)

	var level_lbl := Label.new()
	level_lbl.name = "LevelLabel"
	level_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	level_lbl.add_theme_font_size_override("font_size", 18)
	level_lbl.add_theme_color_override("font_color", COLOR_CYAN)
	card.add_child(level_lbl)

	var cost_lbl := Label.new()
	cost_lbl.name = "CostLabel"
	cost_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	cost_lbl.add_theme_font_size_override("font_size", 24)
	card.add_child(cost_lbl)

	var buy_btn := Button.new()
	buy_btn.name = "BuyButton" # IMPORTANTE: Corretto il nome per farlo trovare dalla update_display
	buy_btn.text = "ACQUISTA"
	buy_btn.custom_minimum_size = Vector2(160, 50)
	
	# Centriamo il bottone usando un MarginContainer
	var btn_margin := MarginContainer.new()
	btn_margin.add_theme_constant_override("margin_left", 30)
	btn_margin.add_theme_constant_override("margin_right", 30)
	btn_margin.add_child(buy_btn)
	card.add_child(btn_margin)

	_style_buy_button(buy_btn)
	buy_btn.pressed.connect(_on_buy_pressed.bind(upg["id"], buy_btn))
	_setup_touch_animations(buy_btn)

	# Trasformiamo la card in un PanelContainer per applicare lo stile correttamente
	var panel := PanelContainer.new()
	panel.add_theme_stylebox_override("panel", style)
	panel.add_child(card)
	panel.set_meta("upgrade_id", upg["id"])
	
	return panel

# --- STILI E ANIMAZIONI ---

func _style_gold_pill(lbl: Label) -> void:
	lbl.add_theme_color_override("font_color", COLOR_GOLD)
	lbl.add_theme_font_size_override("font_size", 32)
	lbl.add_theme_color_override("font_outline_color", Color.BLACK)
	lbl.add_theme_constant_override("outline_size", 6)
	
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.0, 0.0, 0.0, 0.6)
	style.set_corner_radius_all(20)
	style.border_width_all = 2
	style.border_color = COLOR_GOLD.darkened(0.5)
	style.content_margin_left = 20
	style.content_margin_right = 20
	style.content_margin_top = 8
	style.content_margin_bottom = 8
	lbl.add_theme_stylebox_override("normal", style)

func _style_buy_button(btn: Button) -> void:
	var btn_style := StyleBoxFlat.new()
	btn_style.bg_color = COLOR_GOLD.darkened(0.4)
	btn_style.set_corner_radius_all(15)
	btn_style.border_width_all = 3
	btn_style.border_color = COLOR_GOLD
	btn_style.shadow_color = COLOR_GOLD * Color(1, 1, 1, 0.3)
	btn_style.shadow_size = 10

	var btn_disabled := btn_style.duplicate()
	btn_disabled.bg_color = Color(0.1, 0.1, 0.1, 0.8)
	btn_disabled.border_color = Color(0.3, 0.3, 0.3, 0.5)
	btn_disabled.shadow_size = 0

	btn.add_theme_stylebox_override("normal", btn_style)
	btn.add_theme_stylebox_override("hover", btn_style)
	btn.add_theme_stylebox_override("pressed", btn_style.duplicate())
	btn.add_theme_stylebox_override("disabled", btn_disabled)
	btn.add_theme_font_size_override("font_size", 20)
	btn.add_theme_color_override("font_color", COLOR_WHITE)
	btn.add_theme_color_override("font_disabled_color", COLOR_GRAY)
	btn.add_theme_stylebox_override("focus", StyleBoxEmpty.new())

func _style_bottom_button() -> void:
	if not _back_btn: return
	_back_btn.add_theme_font_size_override("font_size", 28)
	_back_btn.custom_minimum_size = Vector2(250, 70)

	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.0, 0.1, 0.2, 0.8)
	style.set_corner_radius_all(35)
	style.border_width_all = 4
	style.border_color = COLOR_CYAN
	style.shadow_color = COLOR_CYAN_GLOW
	style.shadow_size = 20

	_back_btn.add_theme_stylebox_override("normal", style)
	_back_btn.add_theme_stylebox_override("hover", style)
	_back_btn.add_theme_stylebox_override("focus", StyleBoxEmpty.new())

func _setup_touch_animations(btn: Button) -> void:
	if not btn: return
	btn.button_down.connect(func():
		btn.pivot_offset = btn.size / 2.0 
		create_tween().set_trans(Tween.TRANS_CUBIC).tween_property(btn, "scale", Vector2(0.9, 0.9), 0.1)
	)
	btn.button_up.connect(func():
		create_tween().set_trans(Tween.TRANS_BACK).tween_property(btn, "scale", Vector2(1.0, 1.0), 0.2)
	)

func _play_entrance_animation() -> void:
	var delay := 0.0
	for card in _upgrade_cards:
		card.modulate.a = 0.0
		var orig_y = card.position.y
		card.position.y += 50
		var tw = create_tween().set_parallel(true).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		tw.tween_property(card, "modulate:a", 1.0, 0.4).set_delay(delay)
		tw.tween_property(card, "position:y", orig_y, 0.4).set_delay(delay)
		delay += 0.05

# --- LOGICA ---

func _update_display() -> void:
	var gold := _get_gold()
	_gold_label.text = "💰 %d" % gold

	for panel in _upgrade_cards:
		var upg_id: String = panel.get_meta("upgrade_id")
		var level := _get_meta_level(upg_id)
		var upg := _find_upgrade(upg_id)

		# Poiché abbiamo usato un PanelContainer, i figli reali sono dentro il VBoxContainer
		var card: VBoxContainer = panel.get_child(0)
		var level_lbl: Label = card.get_node("LevelLabel")
		var cost_lbl: Label = card.get_node("CostLabel")
		# Il bottone è dentro il MarginContainer
		var buy_btn: Button = card.get_node("MarginContainer/BuyButton")

		level_lbl.text = "Lv. %d / %d" % [level, upg["max_level"]]

		if level >= upg["max_level"]:
			cost_lbl.text = "MASSIMO"
			cost_lbl.add_theme_color_override("font_color", COLOR_GREEN)
			buy_btn.disabled = true
			buy_btn.text = "MAX"
		else:
			var cost := _calculate_cost(upg, level)
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

func _calculate_cost(upg: Dictionary, current_level: int) -> int:
	var base_cost: int = upg["base_cost"]
	var cost_mult: float = upg["cost_mult"]
	return int(base_cost * pow(cost_mult, current_level))

func _on_buy_pressed(upgrade_id: String, btn: Button) -> void:
	var upg := _find_upgrade(upgrade_id)
	var level := _get_meta_level(upgrade_id)
	var cost := _calculate_cost(upg, level)

	if level >= upg["max_level"]:
		return

	if _spend_gold(cost):
		_upgrade_meta(upgrade_id)
		
		# Animazione extra: fa "pulsare" il bottone quando compri con successo
		var tw = create_tween().set_trans(Tween.TRANS_BOUNCE)
		tw.tween_property(btn, "scale", Vector2(1.1, 1.1), 0.1)
		tw.tween_property(btn, "scale", Vector2(1.0, 1.0), 0.2)
		
		_update_display()

func _on_back_pressed() -> void:
	back_pressed.emit()
	queue_free()