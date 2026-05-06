## World.gd
## Main gameplay scene controller. Connects all systems together.
extends Node2D

@onready var player: CharacterBody2D = $Player
@onready var camera: Camera2D = $Player/Camera2D
@onready var spawner: Node = $EnemySpawner
@onready var wave_manager: Node = $WaveManager
@onready var hud: CanvasLayer = $HUD
@onready var level_up_screen: CanvasLayer = $LevelUpScreen
@onready var game_over_screen: CanvasLayer = $GameOverScreen
@onready var floating_text_layer: CanvasLayer = $FloatingTextLayer

var upgrade_system: UpgradeSystem


func _ready() -> void:
	upgrade_system = UpgradeSystem.new()
	add_child(upgrade_system)
	upgrade_system.setup(player)

	# Wire up enemy scenes to spawner
	spawner.enemy_scenes = {
		"batterio": preload("res://scenes/gameplay/enemies/Batterio.tscn"),
		"virus": preload("res://scenes/gameplay/enemies/Virus.tscn"),
	}

	# Connect global signals
	EventBus.player_leveled_up.connect(_on_player_leveled_up)
	EventBus.run_ended.connect(_on_run_ended)
	EventBus.show_floating_text.connect(_on_show_floating_text)
	EventBus.screen_shake_requested.connect(_on_screen_shake)
	EventBus.upgrade_selected.connect(_on_upgrade_selected)

	level_up_screen.hide()
	game_over_screen.hide()


func _on_player_leveled_up(new_level: int) -> void:
	get_tree().paused = true
	var choices := upgrade_system.get_choices(3)
	level_up_screen.show()
	level_up_screen.show_choices(choices, new_level)


func _on_upgrade_selected(upgrade_id: String) -> void:
	upgrade_system.apply_upgrade(upgrade_id)
	level_up_screen.hide()
	get_tree().paused = false


func _on_run_ended(stats: Dictionary) -> void:
	await get_tree().create_timer(1.0).timeout
	game_over_screen.show()
	game_over_screen.setup(stats)
	SaveManager.update_best_stats(stats["time"], stats["kills"])


func _on_show_floating_text(text: String, world_pos: Vector2, color: Color) -> void:
	# Create a floating label
	var label := Label.new()
	label.text = text
	label.modulate = color
	label.add_theme_font_size_override("font_size", 24)
	floating_text_layer.add_child(label)
	# Convert world pos to screen pos
	var screen_pos := get_viewport().get_canvas_transform() * world_pos
	label.position = screen_pos
	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property(label, "position:y", screen_pos.y - 60.0, 0.8)
	tween.tween_property(label, "modulate:a", 0.0, 0.8)
	await tween.finished
	label.queue_free()


func _on_screen_shake(intensity: float, duration: float) -> void:
	var tween := create_tween()
	var original := camera.offset
	for i in 8:
		var offset := Vector2(randf_range(-intensity, intensity), randf_range(-intensity, intensity))
		tween.tween_property(camera, "offset", offset, duration / 8.0)
	tween.tween_property(camera, "offset", original, 0.05)
