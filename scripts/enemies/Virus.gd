## Virus.gd — Fast enemy, flanks the player.
class_name Virus
extends EnemyBase

func _ready() -> void:
	enemy_type = "virus"
	max_health = 15.0
	move_speed = 160.0
	contact_damage = 8.0
	exp_value = 4.0
	super._ready()


func _move_toward_player(_delta: float) -> void:
	if player == null:
		return
	# Slight offset to flank
	var dir := (player.global_position - global_position).normalized()
	var perp := Vector2(-dir.y, dir.x) * sin(Time.get_ticks_msec() * 0.002) * 0.5
	velocity = (dir + perp).normalized() * move_speed
	move_and_slide()