## Batterio.gd — Basic enemy that chases the player.
class_name Batterio
extends EnemyBase

func _ready() -> void:
	enemy_type = "batterio"
	max_health = 30.0
	move_speed = 80.0
	contact_damage = 10.0
	exp_value = 5.0
	super._ready()