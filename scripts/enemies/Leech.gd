## Leech.gd
## Fast enemy that latches onto player and drains HP.
class_name Leech
extends EnemyBase

var _latched: bool = false
var _drain_timer: float = 0.0

func _ready() -> void:
	enemy_type = "leech"
	max_health = 20.0
	move_speed = 120.0  # Very fast!
	contact_damage = 3.0
	exp_value = 8.0
	super._ready()


func _physics_process(delta: float) -> void:
	if player == null or not is_instance_valid(player):
		return
	
	var dist = global_position.distance_to(player.global_position)
	
	if _latched:
		# Drain health while latched
		_drain_timer -= delta
		if _drain_timer <= 0:
			_drain_timer = 0.5
			if player.has_method("take_damage"):
				player.take_damage(contact_damage * 0.5)
		# Move with player
		global_position = global_position.lerp(player.global_position + Vector2(30, 30), 5.0 * delta)
	else:
		# Chase player normally
		_move_toward_player(delta)
		_check_player_contact()
		# Latch on if close
		if dist < 30.0:
			_latched = true
			velocity = Vector2.ZERO


func _die() -> void:
	_latched = false
	super._die()