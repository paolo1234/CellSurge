## RangedCell.gd
## Enemy that shoots projectiles at player from distance.
class_name RangedCell
extends EnemyBase

var _shoot_timer: float = 0.0
var _shoot_interval: float = 3.0
var _retreat_dist: float = 250.0

func _ready() -> void:
	enemy_type = "ranged_cell"
	max_health = 25.0
	move_speed = 50.0  # Slower
	contact_damage = 8.0
	exp_value = 10.0
	super._ready()


func _physics_process(delta: float) -> void:
	if player == null or not is_instance_valid(player):
		return
	
	var dist = global_position.distance_to(player.global_position)
	
	# Keep distance while shooting
	if dist < _retreat_dist:
		# Too close, back up slowly
		var dir = (global_position - player.global_position).normalized()
		velocity = dir * move_speed
		move_and_slide()
	elif dist > _retreat_dist + 50.0:
		# Too far, approach
		var dir = (player.global_position - global_position).normalized()
		velocity = dir * move_speed
		move_and_slide()
	else:
		velocity = Vector2.ZERO
	
	# Shoot at player
	_shoot_timer -= delta
	if _shoot_timer <= 0:
		_shoot_timer = _shoot_interval
		_shoot()


func _shoot() -> void:
	if player == null:
		return
	
	var ProjectileScene = load("res://scenes/gameplay/Projectile.tscn")
	var proj = ProjectileScene.instantiate()
	proj.global_position = global_position
	
	var dir = (player.global_position - global_position).normalized()
	proj.setup(dir, contact_damage * 0.5, 1.0, 1, null)
	proj.color = Color(1.0, 0.5, 0.0)
	get_tree().root.add_child(proj)