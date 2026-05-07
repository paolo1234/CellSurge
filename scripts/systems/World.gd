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


func _ready() -> void:
	_create_background()
	call_deferred("_setup_player_systems")
	_instantiate_ui()
	if joystick and joystick.has_signal("direction_changed"):
		joystick.direction_changed.connect(_on_joystick_input_changed)


func _setup_player_systems() -> void:
	await get_tree().process_frame
	upgrade_system = UpgradeSystem.new()
	add_child(upgrade_system)
	upgrade_system.setup(player)
	if player.stats and hud and hud.has_method("setup_bars"):
		hud.setup_bars(player.stats.max_health)
	_setup_hp_ring()
	spawner.enemy_scenes = {
		"batterio": preload("res://scenes/gameplay/enemies/Batterio.tscn"),
		"virus": preload("res://scenes/gameplay/enemies/Virus.tscn"),
		"fungo": preload("res://scenes/gameplay/enemies/Fungo.tscn"),
	}
	EventBus.player_leveled_up.connect(_on_player_leveled_up)
	EventBus.run_ended.connect(_on_run_ended)
	EventBus.show_floating_text.connect(_on_show_floating_text)
	EventBus.screen_shake_requested.connect(_on_screen_shake)
	EventBus.upgrade_selected.connect(_on_upgrade_selected)
	level_up_screen.hide()
	game_over_screen.hide()
	AudioManager.play_music(AudioManager.music_battle, 2.0)


func _instantiate_ui() -> void:
	var hud_scene := preload("res://scenes/ui/HUD.tscn")
	hud = hud_scene.instantiate()
	add_child(hud)
	level_up_screen = $LevelUpScreen
	var game_over_scene := preload("res://scenes/ui/GameOver.tscn")
	game_over_screen = game_over_scene.instantiate()
	add_child(game_over_screen)
	var joystick_canvas := CanvasLayer.new()
	joystick_canvas.layer = 100
	add_child(joystick_canvas)
	var joystick_scene := preload("res://addons/virtual_joystick/virtual_joystick.tscn")
	joystick = joystick_scene.instantiate()
	joystick.mode = VirtualJoystick.Modes.DYNAMIC
	joystick.action_left = &"move_left"
	joystick.action_right = &"move_right"
	joystick.action_up = &"move_up"
	joystick.action_down = &"move_down"
	joystick.joystick_scale = 1.5
	joystick.base_texture = preload("res://addons/virtual_joystick/textures/base_texture.svg")
	joystick.stick_texture = preload("res://addons/virtual_joystick/textures/stick_texture.svg")
	joystick.process_mode = Node.PROCESS_MODE_ALWAYS
	joystick.dynamic_area_top_margin = 0.5
	joystick.add_to_group("joysticks")
	joystick_canvas.add_child(joystick)


func _setup_hp_ring() -> void:
	var HPRingScript = preload("res://scripts/ui/HPRing.gd")
	hp_ring = Node2D.new()
	hp_ring.set_script(HPRingScript)
	player.add_child(hp_ring)
	hp_ring.setup(player.stats.max_health)


func _create_background() -> void:
	# Full-screen background
	var bg = ColorRect.new()
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.color = Color(0.01, 0.03, 0.08, 1)  # Dark blue ocean background
	bg.z_index = -200
	add_child(bg)
	
	# Ocean decorations (floating particles)
	for i in 30:
		var bubble = ColorRect.new()
		bubble.color = Color(0.3, 0.6, 0.8, 0.15)
		bubble.custom_minimum_size = Vector2(randf_range(2, 8), randf_range(2, 8))
		bubble.position = Vector2(randf_range(0, 1080), randf_range(0, 1920))
		bubble.z_index = -150
		add_child(bubble)
		
		# Animate bubbles rising
		var tween = create_tween()
		tween.set_loops()
		tween.tween_property(bubble, "position:y", bubble.position.y - randf_range(100, 300), randf_range(3, 6))
		tween.tween_property(bubble, "modulate:a", 0.0, randf_range(3, 6))
		# Reset position when reaching top
		tween.tween_property(bubble, "position:y", bubble.position.y + randf_range(1200, 1400), 0)


	# Underwater background image (tiled)
	var bg_image = Sprite2D.new()
	bg_image.name = "Background"
	bg_image.position = Vector2(540, 480)
	bg_image.scale = Vector2(1.5, 1.5)
	var bg_texture = load("res://assets/backgrounds/background.png")
	if bg_texture:
		bg_image.texture = bg_texture
		bg_image.modulate = Color(1, 1, 1, 0.2)
		bg_image.z_index = -100
		bg_image.y_sort_enabled = true
		add_child(bg_image)
		set_process(true)


func _process(delta: float) -> void:
	var bg = get_node_or_null("Background")
	if bg and is_instance_valid(camera):
		var target_pos = camera.global_position * 0.3
		bg.global_position = bg.global_position.lerp(target_pos + Vector2(540, 480), 2.0 * delta)


func _on_player_leveled_up(new_level: int) -> void:
	var choices := upgrade_system.get_choices(3)
	if choices.is_empty():
		return
	AudioManager.play_levelup()
	level_up_screen.show_choices(choices, new_level)


func _on_upgrade_selected(upgrade_id: String) -> void:
	upgrade_system.apply_upgrade(upgrade_id)
	AudioManager.play_pickup()
	level_up_screen.hide()


func _on_run_ended(stats: Dictionary) -> void:
	AudioManager.stop_music(1.0)
	await get_tree().create_timer(1.0).timeout
	game_over_screen.show()
	if game_over_screen.has_method("setup"):
		game_over_screen.setup(stats)
	SaveManager.update_best_stats(stats["time"], stats["kills"])


func _on_show_floating_text(text: String, world_pos: Vector2, color: Color) -> void:
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
	if is_instance_valid(player):
		player.set_meta("joystick_input", direction)