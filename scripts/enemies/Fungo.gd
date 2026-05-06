## Fungo.gd — Tank enemy, slow but high HP and damage.
class_name Fungo
extends EnemyBase

func _ready() -> void:
	enemy_type = "fungo"
	max_health = 60.0
	move_speed = 45.0
	contact_damage = 15.0
	exp_value = 8.0
	super._ready()


func _move_toward_player(_delta: float) -> void:
	if player == null:
		return
	var dir := (player.global_position - global_position).normalized()
	velocity = dir * move_speed
	move_and_slide()
	# Keep minimum distance
	if global_position.distance_to(player.global_position) < 60.0:
		velocity = Vector2.ZERO