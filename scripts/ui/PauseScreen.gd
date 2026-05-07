## PauseScreen.gd
## Full-screen pause menu with settings, stats, and quit option.
class_name PauseScreen
extends CanvasLayer

const COLOR_CYAN := Color(0.0, 0.898, 1.0, 1.0)
const COLOR_CYAN_DIM := Color(0.0, 0.898, 1.0, 0.3)
const COLOR_WHITE := Color(0.941, 0.973, 1.0, 1.0)
const COLOR_RED := Color(1.0, 0.3, 0.3, 1.0)
const COLOR_BG := Color(0.01, 0.02, 0.05, 0.92)

var _sfx_slider: HSlider
var _music_slider: HSlider
var _sfx_value_label: Label
var _music_value_label: Label
var _confirm_panel: PanelContainer


func _ready() -> void:
	layer = 250
	process_mode = Node.PROCESS_MODE_ALWAYS
	_build_ui()
	get_tree().paused = true
	EventBus.game_paused.emit()
	get_tree().call_group("joysticks", "hide")


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		_resume()


func _build_ui() -> void:
	# Dark overlay
	var overlay := ColorRect.new()
	overlay.color = COLOR_BG
	overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(overlay)
	
	# Main content
	var main_vbox := VBoxContainer.new()
	main_vbox.set_anchors_preset(Control.PRESET_FULL_RECT)
	main_vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	main_vbox.add_theme_constant_override("separation", 28)
	main_vbox.offset_left = 60
	main_vbox.offset_right = -60
	main_vbox.offset_top = 80
	main_vbox.offset_bottom = -80
	add_child(main_vbox)
	
	# Title
	var title := Label.new()
	title.text = "⏸  PAUSA"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 56)
	title.add_theme_color_override("font_color", COLOR_WHITE)
	title.add_theme_color_override("font_outline_color", COLOR_CYAN)
	title.add_theme_constant_override("outline_size", 6)
	title.add_theme_color_override("font_shadow_color", Color(0, 0.5, 0.8, 0.4))
	title.add_theme_constant_override("shadow_outline_size", 20)
	main_vbox.add_child(title)
	
	# ── Run Stats ──
	var stats_panel := _create_panel()
	main_vbox.add_child(stats_panel)
	
	var stats_vbox := VBoxContainer.new()
	stats_vbox.add_theme_constant_override("separation", 10)
	stats_panel.add_child(stats_vbox)
	
	var stats_title := Label.new()
	stats_title.text = "STATISTICHE RUN"
	stats_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	stats_title.add_theme_font_size_override("font_size", 22)
	stats_title.add_theme_color_override("font_color", COLOR_CYAN)
	stats_vbox.add_child(stats_title)
	
	var stats_grid := GridContainer.new()
	stats_grid.columns = 2
	stats_grid.add_theme_constant_override("h_separation", 40)
	stats_grid.add_theme_constant_override("v_separation", 8)
	stats_vbox.add_child(stats_grid)
	
	_add_stat_row(stats_grid, "⏱  Tempo", GameManager.get_run_time_string())
	_add_stat_row(stats_grid, "☠  Uccisioni", str(GameManager.kill_count))
	_add_stat_row(stats_grid, "🧬  Livello", str(GameManager.current_level))
	var progress_pct := int(GameManager.run_progress * 100)
	_add_stat_row(stats_grid, "📊  Progresso", "%d%%" % progress_pct)
	
	# ── Volume Settings ──
	var audio_panel := _create_panel()
	main_vbox.add_child(audio_panel)
	
	var audio_vbox := VBoxContainer.new()
	audio_vbox.add_theme_constant_override("separation", 12)
	audio_panel.add_child(audio_vbox)
	
	var audio_title := Label.new()
	audio_title.text = "🔊  AUDIO"
	audio_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	audio_title.add_theme_font_size_override("font_size", 22)
	audio_title.add_theme_color_override("font_color", COLOR_CYAN)
	audio_vbox.add_child(audio_title)
	
	# SFX slider
	var sfx_row := HBoxContainer.new()
	sfx_row.add_theme_constant_override("separation", 16)
	audio_vbox.add_child(sfx_row)
	
	var sfx_label := Label.new()
	sfx_label.text = "SFX"
	sfx_label.custom_minimum_size = Vector2(120, 0)
	sfx_label.add_theme_font_size_override("font_size", 24)
	sfx_label.add_theme_color_override("font_color", COLOR_WHITE)
	sfx_row.add_child(sfx_label)
	
	_sfx_slider = _create_slider()
	_sfx_slider.value = SaveManager.get_setting("sfx_volume", 1.0)
	_sfx_slider.value_changed.connect(_on_sfx_changed)
	sfx_row.add_child(_sfx_slider)
	
	_sfx_value_label = Label.new()
	_sfx_value_label.text = "%d%%" % int(_sfx_slider.value * 100)
	_sfx_value_label.custom_minimum_size = Vector2(70, 0)
	_sfx_value_label.add_theme_font_size_override("font_size", 22)
	_sfx_value_label.add_theme_color_override("font_color", COLOR_CYAN)
	sfx_row.add_child(_sfx_value_label)
	
	# Music slider
	var music_row := HBoxContainer.new()
	music_row.add_theme_constant_override("separation", 16)
	audio_vbox.add_child(music_row)
	
	var music_label := Label.new()
	music_label.text = "Musica"
	music_label.custom_minimum_size = Vector2(120, 0)
	music_label.add_theme_font_size_override("font_size", 24)
	music_label.add_theme_color_override("font_color", COLOR_WHITE)
	music_row.add_child(music_label)
	
	_music_slider = _create_slider()
	_music_slider.value = SaveManager.get_setting("music_volume", 1.0)
	_music_slider.value_changed.connect(_on_music_changed)
	music_row.add_child(_music_slider)
	
	_music_value_label = Label.new()
	_music_value_label.text = "%d%%" % int(_music_slider.value * 100)
	_music_value_label.custom_minimum_size = Vector2(70, 0)
	_music_value_label.add_theme_font_size_override("font_size", 22)
	_music_value_label.add_theme_color_override("font_color", COLOR_CYAN)
	music_row.add_child(_music_value_label)
	
	# ── Buttons ──
	var btn_spacer := Control.new()
	btn_spacer.custom_minimum_size = Vector2(0, 10)
	main_vbox.add_child(btn_spacer)
	
	# Resume button
	var resume_btn := Button.new()
	resume_btn.text = "▶  RIPRENDI"
	resume_btn.custom_minimum_size = Vector2(400, 80)
	resume_btn.add_theme_font_size_override("font_size", 30)
	resume_btn.add_theme_color_override("font_color", Color(0.05, 0.05, 0.05))
	resume_btn.process_mode = Node.PROCESS_MODE_ALWAYS
	resume_btn.pressed.connect(_resume)
	_style_solid_button(resume_btn, COLOR_CYAN)
	main_vbox.add_child(resume_btn)
	
	# ── Debug Section ──
	var debug_container := VBoxContainer.new()
	main_vbox.add_child(debug_container)
	
	var debug_toggle_btn := Button.new()
	debug_toggle_btn.text = "🛠️ MOSTRA DEBUG"
	debug_toggle_btn.custom_minimum_size = Vector2(400, 50)
	debug_toggle_btn.add_theme_font_size_override("font_size", 18)
	debug_toggle_btn.process_mode = Node.PROCESS_MODE_ALWAYS
	_style_outline_button(debug_toggle_btn, Color.GOLD)
	debug_container.add_child(debug_toggle_btn)

	var debug_panel := _create_panel()
	debug_panel.visible = false
	debug_container.add_child(debug_panel)
	
	debug_toggle_btn.pressed.connect(func():
		debug_panel.visible = !debug_panel.visible
		debug_toggle_btn.text = "🛠️ NASCONDI DEBUG" if debug_panel.visible else "🛠️ MOSTRA DEBUG"
	)
	
	var debug_vbox := VBoxContainer.new()
	debug_vbox.add_theme_constant_override("separation", 8)
	debug_panel.add_child(debug_vbox)
	
	var debug_title := Label.new()
	debug_title.text = "DEBUG"
	debug_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	debug_title.add_theme_font_size_override("font_size", 20)
	debug_title.add_theme_color_override("font_color", Color(1, 0.8, 0, 1))
	debug_vbox.add_child(debug_title)
	
	var debug_grid := GridContainer.new()
	debug_grid.columns = 3
	debug_grid.add_theme_constant_override("h_separation", 10)
	debug_grid.add_theme_constant_override("v_separation", 8)
	debug_vbox.add_child(debug_grid)
	
	_add_debug_btn(debug_grid, "+1000 XP", _debug_xp)
	_add_debug_btn(debug_grid, "+Weapon", _debug_weapon)
	_add_debug_btn(debug_grid, "Kill All", _debug_kill)
	_add_debug_btn(debug_grid, "Spawn 5", _debug_spawn)
	_add_debug_btn(debug_grid, "Max Lvl", _debug_level)
	_add_debug_btn(debug_grid, "+9999G", _debug_gold)
	_add_debug_btn(debug_grid, "Full HP", _debug_health)
	_add_debug_btn(debug_grid, "Speed x2", _debug_speed)
	_add_debug_btn(debug_grid, "Instakill", _debug_instakill)
	
	var debug_status := Label.new()
	debug_status.name = "DebugStatus"
	debug_status.text = "Ready"
	debug_status.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	debug_status.add_theme_font_size_override("font_size", 16)
	debug_vbox.add_child(debug_status)
	
	# Quit button
	var quit_btn := Button.new()
	quit_btn.text = "🏠  TORNA AL MENU"
	quit_btn.custom_minimum_size = Vector2(400, 70)
	quit_btn.add_theme_font_size_override("font_size", 24)
	quit_btn.add_theme_color_override("font_color", COLOR_WHITE)
	quit_btn.process_mode = Node.PROCESS_MODE_ALWAYS
	quit_btn.pressed.connect(_show_confirm_quit)
	_style_outline_button(quit_btn, COLOR_RED)
	main_vbox.add_child(quit_btn)
	
	# ── Confirm Quit Dialog (hidden) ──
	_build_confirm_dialog()


func _build_confirm_dialog() -> void:
	_confirm_panel = PanelContainer.new()
	_confirm_panel.set_anchors_preset(Control.PRESET_CENTER)
	_confirm_panel.custom_minimum_size = Vector2(500, 260)
	_confirm_panel.position = Vector2(-250, -130)
	_confirm_panel.visible = false
	_confirm_panel.z_index = 10
	
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.05, 0.02, 0.02, 0.98)
	style.set_corner_radius_all(20)
	style.border_width_left = 3
	style.border_width_right = 3
	style.border_width_top = 3
	style.border_width_bottom = 3
	style.border_color = COLOR_RED
	style.shadow_color = Color(1, 0, 0, 0.2)
	style.shadow_size = 15
	_confirm_panel.add_theme_stylebox_override("panel", style)
	add_child(_confirm_panel)
	
	var vbox := VBoxContainer.new()
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	vbox.add_theme_constant_override("separation", 24)
	_confirm_panel.add_child(vbox)
	
	var warn_label := Label.new()
	warn_label.text = "⚠ SEI SICURO?"
	warn_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	warn_label.add_theme_font_size_override("font_size", 32)
	warn_label.add_theme_color_override("font_color", COLOR_RED)
	vbox.add_child(warn_label)
	
	var desc_label := Label.new()
	desc_label.text = "Il progresso della partita sarà perso."
	desc_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	desc_label.add_theme_font_size_override("font_size", 20)
	desc_label.add_theme_color_override("font_color", Color(0.6, 0.6, 0.6))
	desc_label.autowrap_mode = TextServer.AUTOWRAP_WORD
	vbox.add_child(desc_label)
	
	var btn_row := HBoxContainer.new()
	btn_row.alignment = BoxContainer.ALIGNMENT_CENTER
	btn_row.add_theme_constant_override("separation", 20)
	vbox.add_child(btn_row)
	
	var cancel_btn := Button.new()
	cancel_btn.text = "ANNULLA"
	cancel_btn.custom_minimum_size = Vector2(180, 60)
	cancel_btn.add_theme_font_size_override("font_size", 22)
	cancel_btn.process_mode = Node.PROCESS_MODE_ALWAYS
	cancel_btn.pressed.connect(func(): _confirm_panel.visible = false)
	_style_outline_button(cancel_btn, COLOR_CYAN)
	btn_row.add_child(cancel_btn)
	
	var confirm_btn := Button.new()
	confirm_btn.text = "ESCI"
	confirm_btn.custom_minimum_size = Vector2(180, 60)
	confirm_btn.add_theme_font_size_override("font_size", 22)
	confirm_btn.add_theme_color_override("font_color", Color(0.05, 0.05, 0.05))
	confirm_btn.process_mode = Node.PROCESS_MODE_ALWAYS
	confirm_btn.pressed.connect(_quit_to_menu)
	_style_solid_button(confirm_btn, COLOR_RED)
	btn_row.add_child(confirm_btn)


func _add_stat_row(grid: GridContainer, label_text: String, value_text: String) -> void:
	var lbl := Label.new()
	lbl.text = label_text
	lbl.add_theme_font_size_override("font_size", 22)
	lbl.add_theme_color_override("font_color", Color(0.5, 0.6, 0.65))
	grid.add_child(lbl)
	
	var val := Label.new()
	val.text = value_text
	val.add_theme_font_size_override("font_size", 24)
	val.add_theme_color_override("font_color", COLOR_WHITE)
	val.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	grid.add_child(val)


func _create_panel() -> PanelContainer:
	var panel := PanelContainer.new()
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.02, 0.06, 0.12, 0.85)
	style.set_corner_radius_all(16)
	style.border_width_left = 2
	style.border_width_right = 2
	style.border_width_top = 2
	style.border_width_bottom = 2
	style.border_color = COLOR_CYAN_DIM
	style.content_margin_left = 24
	style.content_margin_right = 24
	style.content_margin_top = 18
	style.content_margin_bottom = 18
	panel.add_theme_stylebox_override("panel", style)
	return panel


func _create_slider() -> HSlider:
	var slider := HSlider.new()
	slider.custom_minimum_size = Vector2(0, 40)
	slider.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	slider.min_value = 0.0
	slider.max_value = 1.0
	slider.step = 0.05
	slider.process_mode = Node.PROCESS_MODE_ALWAYS
	
	var bg := StyleBoxFlat.new()
	bg.bg_color = Color(0.1, 0.1, 0.15, 0.9)
	bg.set_corner_radius_all(8)
	slider.add_theme_stylebox_override("background", bg)
	
	var grabber := StyleBoxFlat.new()
	grabber.bg_color = COLOR_CYAN
	grabber.set_corner_radius_all(10)
	slider.add_theme_stylebox_override("grabber_area", grabber)
	slider.add_theme_stylebox_override("grabber_area_highlight", grabber)
	
	return slider


func _style_solid_button(btn: Button, color: Color) -> void:
	var style := StyleBoxFlat.new()
	style.bg_color = color
	style.set_corner_radius_all(16)
	style.shadow_color = color * Color(1, 1, 1, 0.3)
	style.shadow_size = 10
	
	var pressed := style.duplicate() as StyleBoxFlat
	pressed.bg_color = color.darkened(0.3)
	pressed.shadow_size = 4
	
	btn.add_theme_stylebox_override("normal", style)
	btn.add_theme_stylebox_override("hover", style)
	btn.add_theme_stylebox_override("pressed", pressed)
	btn.add_theme_stylebox_override("focus", StyleBoxEmpty.new())


func _style_outline_button(btn: Button, color: Color) -> void:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0, 0, 0, 0.3)
	style.set_corner_radius_all(16)
	style.border_width_left = 3
	style.border_width_right = 3
	style.border_width_top = 3
	style.border_width_bottom = 3
	style.border_color = color
	
	var pressed := style.duplicate() as StyleBoxFlat
	pressed.bg_color = color * Color(1, 1, 1, 0.15)
	
	btn.add_theme_stylebox_override("normal", style)
	btn.add_theme_stylebox_override("hover", style)
	btn.add_theme_stylebox_override("pressed", pressed)
	btn.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
	btn.add_theme_color_override("font_color", color)


func _on_sfx_changed(value: float) -> void:
	SaveManager.set_setting("sfx_volume", value)
	_sfx_value_label.text = "%d%%" % int(value * 100)


func _on_music_changed(value: float) -> void:
	SaveManager.set_setting("music_volume", value)
	if AudioManager.music_player:
		AudioManager.music_player.volume_db = linear_to_db(value) - 6.0
	_music_value_label.text = "%d%%" % int(value * 100)


func _resume() -> void:
	get_tree().paused = false
	get_tree().call_group("joysticks", "show")
	EventBus.game_resumed.emit()
	queue_free()


func _show_confirm_quit() -> void:
	_confirm_panel.visible = true


func _quit_to_menu() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/ui/MainMenu.tscn")


func _add_debug_btn(parent: Control, text: String, callback: Callable) -> void:
	var btn := Button.new()
	btn.text = text
	btn.custom_minimum_size = Vector2(90, 40)
	btn.add_theme_font_size_override("font_size", 14)
	btn.process_mode = Node.PROCESS_MODE_ALWAYS
	btn.pressed.connect(callback)
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.2, 0.15, 0.05, 0.9)
	style.set_corner_radius_all(8)
	style.border_width_left = 2
	style.border_width_right = 2
	style.border_width_top = 2
	style.border_width_bottom = 2
	style.border_color = Color(1, 0.6, 0, 0.5)
	btn.add_theme_stylebox_override("normal", style)
	btn.add_theme_stylebox_override("hover", style)
	btn.add_theme_stylebox_override("pressed", style)
	parent.add_child(btn)

func _get_debug_status() -> Label:
	return get_node("%PauseScreen/../DebugStatus") as Label

func _debug_xp() -> void:
	# Add a large amount of experience via GameManager
	if GameManager.has_method("add_exp"):
		GameManager.add_exp(1000)
		_show_debug_msg("+1000 XP")
	else:
		_show_debug_msg("add_exp not available")

func _debug_weapon() -> void:
	var weapons = [
		preload("res://scripts/player/weapons/SpikeShoot.gd"),
		preload("res://scripts/player/weapons/ShotgunBlast.gd"),
		preload("res://scripts/player/weapons/NucleusPulse.gd"),
		preload("res://scripts/player/weapons/PlasmaOrbit.gd")
	]
	var rng := RandomNumberGenerator.new()
	rng.randomize()
	var w = weapons[rng.randi() % weapons.size()]
	var player = get_tree().get_first_node_in_group("player")
	if player:
		player.add_weapon(w)
		_show_debug_msg("Added: " + w.resource_path)
	else:
		_show_debug_msg("Player not found")

func _debug_kill() -> void:
	var enemies = get_tree().get_nodes_in_group("enemies")
	var count: int = enemies.size()
	for e in enemies:
		if e.has_method("take_damage"):
			e.take_damage(99999)
	_show_debug_msg("Killed " + str(count))

func _debug_spawn() -> void:
	var spawner = get_tree().get_first_node_in_group("enemy_spawner")
	if spawner and spawner.has_method("spawn_enemy"):
		for i in 5:
			spawner.spawn_enemy()
		_show_debug_msg("Spawned 5")

func _debug_level() -> void:
	# Set run-level for testing purposes
	GameManager.current_level = 99
	GameManager.current_exp = 0.0
	GameManager.exp_to_next_level = 999999.0
	# Force HUD update if needed (HUD listens to player signals, but we can emit a dummy signal)
	_show_debug_msg("Level 99!")

func _debug_gold() -> void:
	# Use GameManager's debug method to safely add gold
	if GameManager.has_method("add_gold_debug"):
		GameManager.add_gold_debug(9999)
		_show_debug_msg("+9999 Gold")
	else:
		_show_debug_msg("Gold debug not available")

func _debug_health() -> void:
	var player = get_tree().get_first_node_in_group("player")
	if player and player.has_method("heal"):
		player.heal(9999)
		_show_debug_msg("Full HP")

func _debug_speed() -> void:
	var was_fast: bool = Engine.time_scale > 1.0
	Engine.time_scale = 1.0 if was_fast else 2.0
	_show_debug_msg("Speed " + ("NORMAL" if was_fast else "x2"))

func _debug_instakill() -> void:
	var player = get_tree().get_first_node_in_group("player")
	if player:
		var current: bool = player.get_meta("instakill", false)
		player.set_meta("instakill", not current)
		_show_debug_msg("Instakill " + ("ON" if not current else "OFF"))

func _show_debug_msg(msg: String) -> void:
	var status = find_child("DebugStatus", true, false)
	if status and status is Label:
		status.text = msg
