## World.gd
## Main gameplay scene controller. Connects all systems together.
extends Node2D

@onready var player: CharacterBody2D = $Player
@onready var camera: Camera2D = $Player/Camera2D
@onready var spawner: Node = $EnemySpawner
@onready var wave_manager: Node = $WaveManager
@onready var floating_text_layer: CanvasLayer = $FloatingTextLayer

var hud: CanvasLayer
var level_up_screen: CanvasLayer
var game_over_screen: CanvasLayer
var joystick: Control
var hp_ring: Node2D

var upgrade_system: UpgradeSystem


func _attach_player_script() -> void:
	if player.get_script() == null:
		var player_script := load("res://scripts/player/Player.gd")
		player.set_script(player_script)
		player._ready()
		# Re-setup systems that depend on player being ready
		if upgrade_system:
			upgrade_system.setup(player)
		if hud and hud.has_method("setup_bars"):
			hud.setup_bars(player.stats.max_health)
		_setup_hp_ring()


func _ready() -> void:
	# Player script is now attached in the scene file
	# But we need to wait for player._ready() to complete before accessing player.stats
	call_deferred("_setup_player_systems")
	
	# Instantiate UI scenes
	_instantiate_ui()

	# Connect joystick to player
	if joystick and joystick.has_signal("input_changed"):
		joystick.input_changed.connect(_on_joystick_input_changed)


func _setup_player_systems() -> void:
	# Wait for player to be ready (in case it's deferred)
	await get_tree().process_frame
	
	upgrade_system = UpgradeSystem.new()
	add_child(upgrade_system)
	upgrade_system.setup(player)

	# Setup HUD with player stats
	if player.stats and hud and hud.has_method("setup_bars"):
		hud.setup_bars(player.stats.max_health)

	# Setup HP Ring around player
	_setup_hp_ring()

	# Wire up enemy scenes to spawner
	spawner.enemy_scenes = {
		"batterio": preload("res://scenes/gameplay/enemies/Batterio.tscn"),
		"virus": preload("res://scenes/gameplay/enemies/Virus.tscn"),
		"fungo": preload("res://scenes/gameplay/enemies/Fungo.tscn"),
	}

	# Connect global signals
	EventBus.player_leveled_up.connect(_on_player_leveled_up)
	EventBus.run_ended.connect(_on_run_ended)
	EventBus.show_floating_text.connect(_on_show_floating_text)
	EventBus.screen_shake_requested.connect(_on_screen_shake)
	EventBus.upgrade_selected.connect(_on_upgrade_selected)

	level_up_screen.hide()
	game_over_screen.hide()


func _instantiate_ui() -> void:
	# Instantiate HUD
	var hud_scene := preload("res://scenes/ui/HUD.tscn")
	hud = hud_scene.instantiate()
	add_child(hud)

	# LevelUpScreen already exists in World.tscn, just get reference
	level_up_screen = $LevelUpScreen

	# Instantiate GameOverScreen
	var game_over_scene := preload("res://scenes/ui/GameOver.tscn")
	game_over_screen = game_over_scene.instantiate()
	add_child(game_over_screen)

	# Instantiate VirtualJoystick
	var joystick_scene := preload("res://scenes/ui/VirtualJoystick.tscn")
	joystick = joystick_scene.instantiate()
	add_child(joystick)


func _setup_hp_ring() -> void:
	var HPRingScript = preload("res://scripts/ui/HPRing.gd")
	hp_ring = Node2D.new()
	hp_ring.set_script(HPRingScript)
	player.add_child(hp_ring)
	hp_ring.setup(player.stats.max_health)


func _on_player_leveled_up(new_level: int) -> void:
	var choices := upgrade_system.get_choices(3)
	if choices.is_empty():
		return
	level_up_screen.show_choices(choices, new_level)


func _on_upgrade_selected(upgrade_id: String) -> void:
	upgrade_system.apply_upgrade(upgrade_id)
	level_up_screen.hide()


func _on_run_ended(stats: Dictionary) -> void:
	await get_tree().create_timer(1.0).timeout
	game_over_screen.show()
	if game_over_screen.has_method("setup"):
		game_over_screen.setup(stats)
	SaveManager.update_best_stats(stats["time"], stats["kills"])


func _on_show_floating_text(text: String, world_pos: Vector2, color: Color) -> void:
	# DESIGN_UI.md: Damage Pop-ups — #FFAC1C, 0.4s, move up + scale + fade
	var label := Label.new()
	label.text = text
	label.modulate = Color("#FFAC1C") if color == Color.YELLOW else color
	label.add_theme_font_size_override("font_size", 24)
	floating_text_layer.add_child(label)
	var screen_pos := get_viewport().get_canvas_transform() * world_pos
	label.position = screen_pos
	label.scale = Vector2(0.8, 0.8)
	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property(label, "position:y", screen_pos.y - 50.0, 0.4)
	tween.tween_property(label, "scale", Vector2(1.2, 1.2), 0.15)
	tween.tween_property(label, "modulate:a", 0.0, 0.4).set_delay(0.1)
	await tween.finished
	label.queue_free()


func _on_screen_shake(intensity: float, duration: float) -> void:
	var tween := create_tween()
	var original := camera.offset
	for i in 8:
		var offset := Vector2(randf_range(-intensity, intensity), randf_range(-intensity, intensity))
		tween.tween_property(camera, "offset", offset, duration / 8.0)
	tween.tween_property(camera, "offset", original, 0.05)


func _on_joystick_input_changed(direction: Vector2) -> void:
	player.set_meta("joystick_input", direction)
