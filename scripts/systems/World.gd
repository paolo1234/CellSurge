## World.gd
## Main gameplay scene controller. Connects all systems together.
extends Node2D

@onready var player: CharacterBody2D = $Player
@onready var camera: Camera2D = $Player/Camera2D
@onready var spawner: Node = $EnemySpawner
@onready var wave_manager: Node = $WaveManager
@onready var floating_text_layer: CanvasLayer = $FloatingTextLayer
@onready var level_up_screen: CanvasLayer = $LevelUpScreen
@onready var game_over_screen: CanvasLayer = $GameOverScreen

var hud: CanvasLayer
var joystick: Control
var hp_ring: Node2D
var upgrade_system: UpgradeSystem
var _bg_particles: Array = []

func _ready() -> void:
	_create_background()
	_setup_joystick()
	_setup_hud()
	call_deferred("_setup_player_systems")

func _setup_joystick() -> void:
	# Clear existing joystick CanvasLayer children
	var joy_layer := $VirtualJoystick
	for c in joy_layer.get_children():
		c.queue_free()
	# Instantiate fresh joystick
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
	joy_layer.add_child(joystick)
	joy_layer.layer = 100

func _setup_hud() -> void:
	# The HUD node exists in scene but may not have a script. Replace it.
	var old_hud := $HUD
	old_hud.queue_free()
	var hud_script := preload("res://scripts/ui/HUD.gd")
	hud = CanvasLayer.new()
	hud.name = "HUD_Live"
	hud.set_script(hud_script)
	add_child(hud)

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

func _setup_hp_ring() -> void:
	var HPRingScript = preload("res://scripts/ui/HPRing.gd")
	hp_ring = Node2D.new()
	hp_ring.set_script(HPRingScript)
	player.add_child(hp_ring)
	hp_ring.setup(player.stats.max_health)

func _create_background() -> void:
	# Layer 1: Deep dark background
	var bg := ColorRect.new()
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.color = Color(0.01, 0.02, 0.06, 1)
	bg.z_index = -200
	add_child(bg)
	# Layer 2: Hex grid pattern (parallax far)
	var grid_node := Node2D.new()
	grid_node.name = "GridLayer"
	grid_node.z_index = -180
	add_child(grid_node)
	for x in range(-5, 15):
		for y in range(-5, 25):
			if randf() > 0.3:
				continue
			var hex := _create_hex(Vector2(x * 120 + (y % 2) * 60, y * 100))
			grid_node.add_child(hex)
	# Layer 3: Vein/capillary lines (parallax mid)
	var vein_node := Node2D.new()
	vein_node.name = "VeinLayer"
	vein_node.z_index = -160
	add_child(vein_node)
	for i in 6:
		var vein := _create_vein()
		vein_node.add_child(vein)
	# Layer 4: Floating bubbles
	for i in 20:
		var bubble := _create_bubble()
		bubble.z_index = -140
		add_child(bubble)
		_bg_particles.append(bubble)
	# Layer 5: Infinite background with parallax
	var bg_texture = load("res://assets/backgrounds/bg1.png")
	if bg_texture:
		var bg_container := Node2D.new()
		bg_container.name = "BGParallax"
		bg_container.z_index = -120
		var tile_size := 300
		var tiles_x := 12
		var tiles_y := 16
		for x in range(tiles_x):
			for y in range(tiles_y):
				var tile := Sprite2D.new()
				tile.texture = bg_texture
				tile.position = Vector2(x * tile_size, y * tile_size)
				tile.modulate = Color(1, 1, 1, 0.25)
				bg_container.add_child(tile)
		bg_container.set_meta("tile_size", tile_size)
		bg_container.set_meta("tiles_x", tiles_x)
		bg_container.set_meta("tiles_y", tiles_y)
		add_child(bg_container)
	# Layer 6: Ambient GPU particles
	var ambient := GPUParticles2D.new()
	ambient.amount = 30
	ambient.lifetime = 8.0
	ambient.z_index = -100
	ambient.position = Vector2(540, 960)
	var mat := ParticleProcessMaterial.new()
	mat.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_BOX
	mat.emission_box_extents = Vector3(600, 1000, 0)
	mat.direction = Vector3(0, -0.5, 0)
	mat.spread = 180.0
	mat.initial_velocity_min = 5.0
	mat.initial_velocity_max = 15.0
	mat.gravity = Vector3(0, 0, 0)
	mat.scale_min = 1.0
	mat.scale_max = 3.0
	mat.color = Color(0.0, 0.6, 0.8, 0.15)
	ambient.process_material = mat
	add_child(ambient)

func _create_hex(pos: Vector2) -> Polygon2D:
	var hex := Polygon2D.new()
	var pts: PackedVector2Array = []
	var sz := randf_range(15, 35)
	for i in 6:
		var angle := (TAU / 6) * i + PI / 6
		pts.append(Vector2.from_angle(angle) * sz)
	hex.polygon = pts
	hex.color = Color(0.0, 0.15, 0.25, randf_range(0.03, 0.08))
	hex.position = pos
	return hex

func _create_vein() -> Line2D:
	var line := Line2D.new()
	var start := Vector2(randf_range(-200, 1300), randf_range(-200, 2200))
	var pts: PackedVector2Array = [start]
	var cur := start
	for i in randi_range(4, 8):
		cur += Vector2(randf_range(-150, 150), randf_range(80, 200))
		pts.append(cur)
	line.points = pts
	line.width = randf_range(1.5, 4.0)
	line.default_color = Color(0.3, 0.05, 0.05, randf_range(0.06, 0.12))
	line.joint_mode = Line2D.LINE_JOINT_ROUND
	line.begin_cap_mode = Line2D.LINE_CAP_ROUND
	line.end_cap_mode = Line2D.LINE_CAP_ROUND
	return line

func _create_bubble() -> Polygon2D:
	var b := Polygon2D.new()
	var pts: PackedVector2Array = []
	var r := randf_range(3, 10)
	for i in 8:
		pts.append(Vector2.from_angle((TAU / 8) * i) * r)
	b.polygon = pts
	b.color = Color(0.1, 0.4, 0.6, randf_range(0.05, 0.15))
	b.position = Vector2(randf_range(0, 1080), randf_range(0, 1920))
	var tw := create_tween()
	tw.set_loops()
	var dur := randf_range(4, 8)
	tw.tween_property(b, "position:y", b.position.y - randf_range(200, 500), dur)
	tw.tween_property(b, "modulate:a", 0.0, 1.0)
	tw.tween_callback(func():
		b.position.y += randf_range(1500, 2000)
		b.modulate.a = 1.0)
	return b

func _process(delta: float) -> void:
	if is_instance_valid(camera):
		var cp := camera.global_position
		var gl := get_node_or_null("GridLayer")
		if gl: gl.position = gl.position.lerp(-cp * 0.15, 2.0 * delta)
		var vl := get_node_or_null("VeinLayer")
		if vl: vl.position = vl.position.lerp(-cp * 0.25, 2.0 * delta)
		var bi := get_node_or_null("BGImage")
		if bi: bi.global_position = bi.global_position.lerp(cp * 0.3 + Vector2(540, 480), 2.0 * delta)
		var bp := get_node_or_null("BGParallax")
		if bp:
			var tile_size: float = bp.get_meta("tile_size", 300)
			var parallax_factor := 0.1
			var world_offset := cp * parallax_factor
			bp.global_position = -world_offset
			for tile in bp.get_children():
				var tile_pos: Vector2 = tile.position
				var wrapped_x := fmod(tile_pos.x + world_offset.x, tile_size * 12)
				var wrapped_y := fmod(tile_pos.y + world_offset.y, tile_size * 16)
				if wrapped_x < 0: wrapped_x += tile_size * 12
				if wrapped_y < 0: wrapped_y += tile_size * 16
				tile.position = Vector2(wrapped_x, wrapped_y) - Vector2(world_offset.x, world_offset.y)

func _on_player_leveled_up(new_level: int) -> void:
	var choices := upgrade_system.get_choices(3)
	if choices.is_empty():
		return
	AudioManager.play_levelup()
	if is_instance_valid(player):
		ParticleFactory.create_levelup_effect(player.global_position, self)
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