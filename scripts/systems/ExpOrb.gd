## ExpOrb.gd
## Experience orb dropped by enemies. Flies toward player when in range.
class_name ExpOrb
extends Area2D

const ATTRACT_SPEED := 400.0

var _attracting: bool = false
var _target: Node2D = null
var _exp_value: float = 5.0

func _ready() -> void:
	add_to_group("exp_orb")
	area_entered.connect(_on_area_entered)

func setup(exp_value: float) -> void:
	_exp_value = exp_value
	_attracting = false
	_target = null
	show()

func attract(target: Node2D) -> void:
	_attracting = true
	_target = target

func _process(delta: float) -> void:
	if not visible:
		return
	var player := get_tree().get_first_node_in_group("player")
	if player == null:
		return
	if not _attracting:
		var dist := global_position.distance_to(player.global_position)
		if player.stats and dist < player.stats.pickup_radius:
			_attracting = true
			_target = player
	if _attracting and _target:
		var dir := (_target.global_position - global_position).normalized()
		global_position += dir * ATTRACT_SPEED * delta
		if global_position.distance_to(_target.global_position) < 20.0:
			_collect()

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("player"):
		_collect()

func _collect() -> void:
	if not visible:
		return
	hide()
	GameManager.add_exp(_exp_value)
	AudioManager.play_pickup()
	# Create pickup particle effect
	ParticleFactory.create_pickup_effect(global_position, get_parent())
	# Free the orb
	queue_free()

func reset() -> void:
	_attracting = false
	_target = null
