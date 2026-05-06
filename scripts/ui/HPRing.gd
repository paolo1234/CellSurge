## HPRing.gd
## Draws a circular health indicator around the player using _draw().
## Must be added as a child of the Player node in world space.
extends Node2D

const COLOR_HIGH := Color("#39FF14")   # Verde Acido
const COLOR_LOW := Color("#FF2400")    # Rosso Scarlatto

var current_hp: float = 100.0
var max_hp: float = 100.0
var ring_radius: float = 28.0
var ring_thickness: float = 3.5
var _pulse_tween: Tween


func _ready() -> void:
	z_index = -1
	EventBus.player_damaged.connect(_on_hp_changed)
	EventBus.player_healed.connect(_on_hp_changed)


func setup(p_max_hp: float) -> void:
	max_hp = p_max_hp
	current_hp = p_max_hp
	queue_redraw()


func _on_hp_changed(_amount: float, new_hp: float) -> void:
	current_hp = new_hp
	queue_redraw()

	# Pulse effect when low HP
	if current_hp / max_hp < 0.25:
		_start_pulse()
	else:
		_stop_pulse()


func _draw() -> void:
	if max_hp <= 0.0:
		return
	var ratio := clampf(current_hp / max_hp, 0.0, 1.0)

	# Background ring (dark, full circle)
	draw_arc(Vector2.ZERO, ring_radius, 0.0, TAU, 64,
		Color(0.1, 0.1, 0.1, 0.4), ring_thickness, true)

	if ratio <= 0.0:
		return

	# Health color: green -> red based on ratio
	var color: Color
	if ratio > 0.5:
		color = COLOR_HIGH
	elif ratio > 0.25:
		color = COLOR_HIGH.lerp(COLOR_LOW, 1.0 - (ratio - 0.25) / 0.25)
	else:
		color = COLOR_LOW

	# Draw health arc (clockwise from top)
	var start_angle := -PI / 2.0
	var end_angle := start_angle + TAU * ratio
	draw_arc(Vector2.ZERO, ring_radius, start_angle, end_angle, 64,
		color, ring_thickness, true)


func _start_pulse() -> void:
	if _pulse_tween and _pulse_tween.is_running():
		return
	_pulse_tween = create_tween()
	_pulse_tween.set_loops(0)
	_pulse_tween.tween_property(self, "modulate:a", 0.4, 0.3)
	_pulse_tween.tween_property(self, "modulate:a", 1.0, 0.3)


func _stop_pulse() -> void:
	if _pulse_tween:
		_pulse_tween.kill()
	modulate.a = 1.0
