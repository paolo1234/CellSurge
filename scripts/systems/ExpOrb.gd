## ExpOrb.gd
## Experience orb dropped by enemies. Flies toward player when in range.
class_name ExpOrb
extends Area2D

const ATTRACT_SPEED := 400.0
const EXP_AMOUNT := 5.0

var _attracting: bool = false
var _target: Node2D = null
var _exp_value: float = EXP_AMOUNT


func _ready() -> void:
	add_to_group("exp_orb")
	body_entered.connect(_on_body_entered)


func setup(exp_value: float) -> void:
	_exp_value = exp_value
	_attracting = false
	_target = null
	show()


func attract(target: Node2D) -> void:
	_attracting = true
	_target = target


func _process(delta: float) -> void:
	if not _attracting or _target == null:
		return
	var dir := (_target.global_position - global_position).normalized()
	position += dir * ATTRACT_SPEED * delta
	if global_position.distance_to(_target.global_position) < 20.0:
		_collect()


func _on_body_entered(body: Node) -> void:
	if body.is_in_group("player"):
		_collect()


func _collect() -> void:
	GameManager.add_exp(_exp_value)
	hide()
	queue_free()


func reset() -> void:
	_attracting = false
	_target = null
