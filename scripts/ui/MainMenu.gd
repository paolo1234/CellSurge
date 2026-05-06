## MainMenu.gd
## Main menu controller — Bioluminescenza theme.
class_name MainMenu
extends Control

const COLOR_CYAN := Color("#00FFFF")
const COLOR_BG := Color(0.01, 0.01, 0.03, 1.0)
const COLOR_GOLD := Color("#FFAC1C")
const COLOR_WHITE := Color("#F0F8FF")

@onready var play_btn: Button = $VBoxContainer/PlayButton
@onready var settings_btn: Button = $VBoxContainer/SettingsButton
@onready var upgrades_btn: Button = $VBoxContainer/UpgradesButton
@onready var title_label: Label = $TitleLabel
@onready var gold_label: Label = $GoldLabel
@onready var background: ColorRect = $Background


func _ready() -> void:
	play_btn.pressed.connect(_on_play_pressed)
	settings_btn.pressed.connect(_on_settings_pressed)
	upgrades_btn.pressed.connect(_on_upgrades_pressed)
	_update_gold_display()
	_apply_bio_theme()


func _apply_bio_theme() -> void:
	# Background — deep dark
	if background:
		background.color = COLOR_BG

	# Title — Ciano glow feel
	if title_label:
		title_label.modulate = COLOR_CYAN
		title_label.add_theme_font_size_override("font_size", 64)

	# Gold label
	if gold_label:
		gold_label.modulate = COLOR_GOLD
		gold_label.add_theme_font_size_override("font_size", 22)

	# Buttons — dark glass with ciano borders
	_style_button(play_btn, COLOR_CYAN, "▶  PLAY")
	_style_button(upgrades_btn, Color(0.3, 0.5, 1.0), "🧬  UPGRADES")
	_style_button(settings_btn, Color(0.4, 0.4, 0.5), "⚙  SETTINGS")


func _style_button(btn: Button, accent: Color, text: String) -> void:
	if btn == null:
		return
	btn.text = text
	btn.add_theme_font_size_override("font_size", 26)
	btn.add_theme_color_override("font_color", COLOR_WHITE)
	btn.add_theme_color_override("font_hover_color", accent)

	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.04, 0.04, 0.08, 0.9)
	style.set_corner_radius_all(16)
	style.border_width_left = 2
	style.border_width_top = 2
	style.border_width_right = 2
	style.border_width_bottom = 2
	style.border_color = accent.darkened(0.4)

	var hover := style.duplicate()
	hover.border_color = accent
	hover.bg_color = Color(0.06, 0.06, 0.12, 0.95)

	var pressed := style.duplicate()
	pressed.bg_color = Color(0.08, 0.08, 0.16, 0.95)
	pressed.border_color = accent.lightened(0.2)

	btn.add_theme_stylebox_override("normal", style)
	btn.add_theme_stylebox_override("hover", hover)
	btn.add_theme_stylebox_override("pressed", pressed)
	btn.add_theme_stylebox_override("focus", StyleBoxEmpty.new())


func _update_gold_display() -> void:
	if gold_label and SaveManager.has_method("get_gold"):
		gold_label.text = "💰 %d" % SaveManager.get_gold()


func _on_play_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/gameplay/World.tscn")


func _on_settings_pressed() -> void:
	# TODO: Settings menu
	pass


func _on_upgrades_pressed() -> void:
	# TODO: Meta-upgrade menu
	pass
