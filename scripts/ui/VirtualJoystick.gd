## VirtualJoystick.gd
## Floating touch-based virtual joystick for mobile controls.
## Appears where the user touches, disappears on release.
## DESIGN_UI.md: Base grey 20%, Knob white 50%, floating behavior.
class_name VirtualJoystick
extends Control

signal input_changed(direction: Vector2)

@export var deadzone: float = 0.15
@export var max_distance: float = 80.0

var _touch_id: int = -1
var _center: Vector2 = Vector2.ZERO
var _direction: Vector2 = Vector2.ZERO
var _base: ColorRect
var _knob: ColorRect


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	# Cover bottom half of screen for touch detection
	set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	offset_top = -500.0
	_build_visuals()
	_hide_joystick()


func _build_visuals() -> void:
	# Base circle (grey, 20% opacity)
	_base = ColorRect.new()
	_base.color = Color(0.5, 0.5, 0.5, 0.2)
	_base.custom_minimum_size = Vector2(120, 120)
	_base.size = Vector2(120, 120)
	_base.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_base)

	# Knob (white, 50% opacity)
	_knob = ColorRect.new()
	_knob.color = Color(1.0, 1.0, 1.0, 0.5)
	_knob.custom_minimum_size = Vector2(50, 50)
	_knob.size = Vector2(50, 50)
	_knob.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_knob)


func _gui_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		if event.pressed:
			if _touch_id == -1:
				_touch_id = event.index
				_center = event.position
				_show_joystick()
				_update_visuals(_center)
				_calculate_direction(_center)
		else:
			if event.index == _touch_id:
				_reset()

	elif event is InputEventScreenDrag:
		if event.index == _touch_id:
			_update_visuals(event.position)
			_calculate_direction(event.position)


func _update_visuals(pos: Vector2) -> void:
	var offset := pos - _center
	if offset.length() > max_distance:
		offset = offset.normalized() * max_distance

	var stick_pos := _center + offset
	_base.position = _center - _base.size * 0.5
	_knob.position = stick_pos - _knob.size * 0.5


func _calculate_direction(touch_pos: Vector2) -> void:
	var offset := touch_pos - _center
	var length := offset.length()

	if length < deadzone * max_distance:
		_direction = Vector2.ZERO
	else:
		var normalized := offset.normalized()
		var strength := clampf(
			(length - deadzone * max_distance) / (max_distance - deadzone * max_distance),
			0.0, 1.0
		)
		_direction = normalized * strength

	input_changed.emit(_direction)


func _show_joystick() -> void:
	_base.visible = true
	_knob.visible = true


func _hide_joystick() -> void:
	_base.visible = false
	_knob.visible = false


func _reset() -> void:
	_touch_id = -1
	_direction = Vector2.ZERO
	input_changed.emit(Vector2.ZERO)
	_hide_joystick()


func get_input() -> Vector2:
	return _direction
