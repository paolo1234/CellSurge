## ShotgunBlast.gd
## Fires a burst of projectiles in a cone toward movement direction.
## Uses ObjectPool for performance.
class_name ShotgunBlast
extends WeaponBase

@export var pellets: int = 5
@export var spread_angle: float = 0.6  # radians

var _pool: ObjectPool


func _ready() -> void:
	weapon_id = "shotgun_blast"
	base_damage = 8.0
	base_fire_rate = 0.7
	base_area = 1.0
	max_level = 5
	level_ups = [
		{"damage": 1.4, "fire_rate": 1.3},
		{"damage": 1.7, "fire_rate": 1.4},
		{"damage": 2.0, "fire_rate": 1.5},
		{"damage": 2.3, "fire_rate": 1.6},
	]
	super._ready()
	var proj_scene := load("res://scenes/gameplay/Projectile.tscn")
	var world := get_tree().current_scene
	_pool = ObjectPool.new(proj_scene, 30, world)


func _fire() -> void:
	var count = pellets + level
	# Use player's last movement direction
	var base_angle := -PI / 2  # Default upward
	if player and "last_move_angle" in player:
		base_angle = player.last_move_angle
	elif player:
		# Fallback: aim at nearest enemy
		var enemy = player.get_nearest_enemy()
		if enemy:
			base_angle = (enemy.global_position - player.global_position).angle()
	
	var angle_step = spread_angle / maxf(count - 1, 1)
	for i in count:
		var offset: float = -spread_angle / 2.0 + angle_step * i
		var angle = base_angle + offset + randf_range(-0.08, 0.08)
		_spawn_pellet(angle)
	AudioManager.play_shoot()


func _spawn_pellet(angle: float) -> void:
	var proj = _pool.get_node()
	if proj == null:
		return
	proj.global_position = player.global_position
	var dir = Vector2.from_angle(angle)
	proj.setup(dir, _get_damage(), _get_area() * 0.6, 1, _pool)
	proj.modulate = Color(1, 0.8, 0.2)  # Yellow shotgun pellets