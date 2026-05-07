## MainMenu.gd
## Main menu controller — Tema Bioluminescenza fedele all'immagine.
class_name MainMenu
extends Control

const COLOR_CYAN := Color(0.0, 0.8, 1.0, 1.0) # Ciano brillante
const COLOR_CYAN_GLOW := Color(0.0, 1.0, 1.0, 0.6) # Bagliore ciano
const COLOR_BG := Color(0.02, 0.05, 0.1, 1.0) # Sfondo scuro abissale
const COLOR_GOLD := Color("#FFD700")
const COLOR_WHITE := Color("#FFFFFF")

# --- RIFERIMENTI AI NODI ---
@onready var background: ColorRect = $Background
@onready var title_label: Label = $TitleLabel

# Top Bar
@onready var store_btn: Button = $StoreButton
@onready var gold_label: Label = $TopBar/GoldLabel

# Centro
@onready var play_btn: Button = $CenterContainer/PlayButton

# Bottom Panel & Nav
@onready var bottom_panel: PanelContainer = $BottomPanel
@onready var bottom_nav: HBoxContainer = $BottomPanel/BottomNav
@onready var profile_btn: Button = $BottomPanel/BottomNav/ProfileButton
@onready var settings_btn: Button = $BottomPanel/BottomNav/SettingsButton
@onready var records_btn: Button = $BottomPanel/BottomNav/RecordsButton

var _play_pulse_tween: Tween

func _ready() -> void:
	_setup_layout_spacings()
	_connect_buttons()
	_apply_neon_theme()
	_update_gold_display()
	
	# Avvia l'animazione del tasto centrale
	_start_play_button_pulse()

# Imposta i margini dei contenitori per distanziare bene gli elementi
func _setup_layout_spacings() -> void:
	if $TopBar:
		$TopBar.add_theme_constant_override("separation", 20)
		$TopBar.custom_minimum_size.y = 80
	if bottom_nav:
		bottom_nav.add_theme_constant_override("separation", 24)
	if title_label:
		title_label.position.y = 130 # Spinge il titolo un po' in basso
		title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

func _connect_buttons() -> void:
	if play_btn: play_btn.pressed.connect(_on_play_pressed)
	if settings_btn: settings_btn.pressed.connect(_on_settings_pressed)
	if store_btn: store_btn.pressed.connect(_on_store_pressed)
	if profile_btn: profile_btn.pressed.connect(_on_profile_pressed)
	
	# Usiamo un ciclo per applicare l'animazione touch (squish) a tutti i bottoni
	for btn in [play_btn, settings_btn, store_btn, profile_btn, records_btn]:
		_setup_touch_animations(btn)

func _apply_neon_theme() -> void:
	if background: background.color = COLOR_BG

	# Titolo — Ciano glow feel
	if title_label:
		title_label.text = "CELL SURGE"
		title_label.add_theme_font_size_override("font_size", 72)
		title_label.add_theme_color_override("font_color", COLOR_WHITE)
		title_label.add_theme_color_override("font_outline_color", COLOR_CYAN.darkened(0.2))
		title_label.add_theme_constant_override("outline_size", 8)
		title_label.add_theme_color_override("font_shadow_color", COLOR_CYAN_GLOW)
		title_label.add_theme_constant_override("shadow_outline_size", 25)

	# Etichetta Oro - Stile "Pillola"
	_style_gold_pill(gold_label)

	# Riquadro inferiore (Il contenitore che racchiude i 3 bottoni)
	_style_bottom_panel(bottom_panel)

	# --- STILE BOTTONI ---
	_style_outline_button(store_btn, "🛒 NEGOZIO", Vector2(220, 60))
	
	# Tasto Gioca - Pieno, Ciano, Grande
	_style_solid_button(play_btn, "▶\nGIOCA", Vector2(220, 220))
	
	# Tasti navigazione - Vuoti con bordo ciano
	_style_outline_button(profile_btn, "👤\nPROFILO", Vector2(130, 130))
	_style_outline_button(settings_btn, "⚙\nIMPOSTAZIONI", Vector2(130, 130))
	_style_outline_button(records_btn, "🏆\nRECORD", Vector2(130, 130))

# --- FUNZIONI DI STILE (IL DESIGN) ---

func _style_solid_button(btn: Button, test_str: String, min_size: Vector2) -> void:
	if not btn: return
	btn.text = test_str
	btn.custom_minimum_size = min_size
	btn.add_theme_font_size_override("font_size", 42)
	btn.add_theme_color_override("font_color", COLOR_WHITE)
	btn.add_theme_color_override("font_outline_color", Color.BLACK)
	btn.add_theme_constant_override("outline_size", 6)
	
	var style := StyleBoxFlat.new()
	style.bg_color = COLOR_CYAN.darkened(0.1)
	style.set_corner_radius_all(40) # Smussa gli angoli (Esagono morbido)
	style.border_width_left = 4
	style.border_width_right = 4
	style.border_width_top = 4
	style.border_width_bottom = 4
	style.border_color = COLOR_WHITE
	style.shadow_color = COLOR_CYAN_GLOW
	style.shadow_size = 30
	
	_apply_button_states(btn, style)

func _style_outline_button(btn: Button, test_str: String, min_size: Vector2) -> void:
	if not btn: return
	btn.text = test_str
	btn.custom_minimum_size = min_size
	btn.add_theme_font_size_override("font_size", 22)
	btn.add_theme_color_override("font_color", COLOR_WHITE)
	
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.0, 0.1, 0.2, 0.6) # Fondo semi-trasparente scuro
	style.set_corner_radius_all(25)
	style.border_width_left = 4
	style.border_width_right = 4
	style.border_width_top = 4
	style.border_width_bottom = 4
	style.border_color = COLOR_CYAN
	style.shadow_color = COLOR_CYAN * Color(1, 1, 1, 0.3)
	style.shadow_size = 15
	
	_apply_button_states(btn, style)

func _style_bottom_panel(panel: PanelContainer) -> void:
	if not panel: return
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.0, 0.05, 0.1, 0.8)
	style.set_corner_radius_all(30)
	style.border_width_left = 4
	style.border_width_right = 4
	style.border_width_top = 4
	style.border_width_bottom = 4
	style.border_color = COLOR_CYAN.darkened(0.4)
	style.content_margin_left = 20
	style.content_margin_right = 20
	style.content_margin_top = 20
	style.content_margin_bottom = 20
	panel.add_theme_stylebox_override("panel", style)

func _style_gold_pill(lbl: Label) -> void:
	if not lbl: return
	lbl.add_theme_color_override("font_color", COLOR_GOLD)
	lbl.add_theme_font_size_override("font_size", 32)
	
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.0, 0.0, 0.0, 0.6)
	style.set_corner_radius_all(30)
	style.border_width_left = 3
	style.border_width_right = 3
	style.border_width_top = 3
	style.border_width_bottom = 3
	style.border_color = COLOR_CYAN
	style.content_margin_left = 24
	style.content_margin_right = 24
	lbl.add_theme_stylebox_override("normal", style)

func _apply_button_states(btn: Button, base_style: StyleBoxFlat) -> void:
	var pressed := base_style.duplicate() as StyleBoxFlat
	pressed.bg_color = base_style.bg_color.darkened(0.4)
	pressed.shadow_size = base_style.shadow_size / 2

	btn.add_theme_stylebox_override("normal", base_style)
	btn.add_theme_stylebox_override("hover", base_style)
	btn.add_theme_stylebox_override("pressed", pressed)
	btn.add_theme_stylebox_override("focus", StyleBoxEmpty.new())

# --- ANIMAZIONI ---

# Animazione Tocco (Mobile) al posto dell'hover del mouse
func _setup_touch_animations(btn: Button) -> void:
	if not btn: return
	btn.button_down.connect(func():
		btn.pivot_offset = btn.size / 2.0 
		var tween = create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
		tween.tween_property(btn, "scale", Vector2(0.9, 0.9), 0.1)
	)
	btn.button_up.connect(func():
		var tween = create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		tween.tween_property(btn, "scale", Vector2(1.0, 1.0), 0.2)
	)

# Fa pulsare il tasto Gioca
func _start_play_button_pulse() -> void:
	if not play_btn: return
	play_btn.pivot_offset = play_btn.size / 2.0 
	_play_pulse_tween = create_tween().set_loops().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	_play_pulse_tween.tween_property(play_btn, "scale", Vector2(1.05, 1.05), 1.2)
	_play_pulse_tween.tween_property(play_btn, "scale", Vector2(1.0, 1.0), 1.2)

# --- LOGICA ---

func _update_gold_display() -> void:
	if gold_label:
		var gold := 0
		if has_node("/root/SaveManager"):
			gold = get_node("/root/SaveManager").get_gold()
		gold_label.text = "💰 %d" % gold

func _on_play_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/gameplay/World.tscn")

func _on_settings_pressed() -> void:
	visible = false
	var settings := preload("res://scripts/ui/SettingsMenu.gd").new()
	settings.back_pressed.connect(_on_menu_closed)
	get_tree().root.add_child(settings)


func _on_store_pressed() -> void:
	visible = false
	var upgrades := preload("res://scripts/ui/UpgradesMenu.gd").new()
	upgrades.back_pressed.connect(_on_menu_closed)
	get_tree().root.add_child(upgrades)


func _on_profile_pressed() -> void:
	visible = false
	var profile := preload("res://scripts/ui/ProfileMenu.gd").new()
	profile.back_pressed.connect(_on_menu_closed)
	get_tree().root.add_child(profile)


func _on_menu_closed() -> void:
	visible = true