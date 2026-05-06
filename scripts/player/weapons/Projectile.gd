## Projectile.gd
## Generic projectile used by pool. Travels in a direction, hits enemies.
class_name Projectile
extends Area2D

const SPEED := 500.0

var _direction: Vector2 = Vector2.RIGHT
var _damage: float = 10.0
var _scale_factor: float = 1.0
var _pierce: int = 0
var _pierce_count: int = 0
var _pool: ObjectPool
var _lifetime: float = 3.0
var _elapsed: float = 0.0
var _hit_enemies: Array = []  # prevent double hit


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func setup(direction: Vector2, damage: float, area: float, pierce: int, pool: ObjectPool) -> void:
	_direction = direction.normalized()
	_damage = damage
	_scale_factor = area
	_pierce = pierce
	_pierce_count = 0
	_elapsed = 0.0
	_hit_enemies.clear()
	scale = Vector2.ONE * area
	rotation = _direction.angle()
	show()
	process_mode = Node.PROCESS_MODE_INHERIT


func _process(delta: float) -> void:
	_elapsed += delta
	if _elapsed >= _lifetime:
		_return_to_pool()
		return
	position += _direction * SPEED * delta


func _on_body_entered(body: Node) -> void:
	if not body.is_in_group("enemies"):
		return
	if body in _hit_enemies:
		return
	_hit_enemies.append(body)
	if body.has_method("take_damage"):
		body.take_damage(_damage)
	if _pierce_count >= _pierce:
		_return_to_pool()
	else:
		_pierce_count += 1


func _return_to_pool() -> void:
	if _pool:
		_pool.release(self)
	else:
		hide()
		process_mode = Node.PROCESS_MODE_DISABLED


func reset() -> void:
	_hit_enemies.clear()
	_elapsed = 0.0
	_pierce_count = 0
