## SpikeShoot.gd
## Shoots spikes in all directions from the player.
## Uses ObjectPool for performance.
class_name SpikeShoot
extends WeaponBase

var _pool: ObjectPool


func _ready() -> void:
	weapon_id = "spike_shoot"
	base_damage = 15.0
	base_fire_rate = 1.5
	base_area = 1.0
	max_level = 5
	level_ups = [
		{"damage": 1.5, "fire_rate": 1.2, "area": 1.2},
		{"damage": 2.0, "fire_rate": 1.4, "area": 1.4},
		{"damage": 2.5, "fire_rate": 1.6, "area": 1.6},
		{"damage": 3.0, "fire_rate": 1.8, "area": 1.8},
	]
	super._ready()
	var proj_scene := load("res://scenes/gameplay/Projectile.tscn")
	var world := get_tree().current_scene
	_pool = ObjectPool.new(proj_scene, 30, world)


func _fire() -> void:
	var count = 4 + level
	var angle_step = TAU / count
	for i in count:
		var angle = angle_step * i + randf() * 0.3
		_spawn_spike(angle)
	AudioManager.play_shoot()


func _spawn_spike(angle: float) -> void:
	var spike = _pool.get_node()
	if spike == null:
		return
	spike.global_position = player.global_position
	var dir = Vector2.from_angle(angle)
	var pierce := 1 + (level - 1)
	spike.setup(dir, _get_damage(), _get_area(), pierce, _pool)
	# Color based on level
	var colors := [Color(1, 0.3, 0.3), Color(1, 0.5, 0.2), Color(1, 0.8, 0.2), Color(1, 1, 0.4), Color(1, 1, 0.8)]
	spike.modulate = colors[mini(level - 1, colors.size() - 1)]