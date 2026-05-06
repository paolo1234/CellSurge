## NucleusPulse.gd
## First weapon: fires N projectiles in a radial pattern.
## Lvl 1: 4 projectiles | Lvl 3: 6 | Lvl 5: 8 + bigger
class_name NucleusPulse
extends WeaponBase

@export var projectile_scene: PackedScene

var _pool: ObjectPool


func _ready() -> void:
	weapon_id = "nucleus_pulse"
	base_damage = 15.0
	base_fire_rate = 0.8
	level_ups = [
		{"damage": 1.2, "projectile_count": 1},
		{"damage": 1.4, "fire_rate": 1.1},
		{"damage": 1.6, "projectile_count": 2, "area": 1.2},
		{"damage": 2.0, "fire_rate": 1.2, "projectile_count": 2},
	]
	super._ready()
	if projectile_scene == null:
		projectile_scene = load("res://scenes/gameplay/Projectile.tscn")
	var world := get_tree().current_scene
	_pool = ObjectPool.new(projectile_scene, 40, world)


func _fire() -> void:
	var count := _get_projectile_count()
	var angle_step := TAU / count
	for i in count:
		var angle := angle_step * i
		var direction := Vector2.from_angle(angle)
		_spawn_projectile(direction)


func _get_projectile_count() -> int:
	var bonus := 0
	for i in level - 1:
		if i < level_ups.size():
			bonus += int(level_ups[i].get("projectile_count", 0))
	if player:
		bonus += player.stats.projectile_count
	return 4 + bonus


func _spawn_projectile(direction: Vector2) -> void:
	var proj = _pool.get_node()
	if proj == null:
		return
	proj.global_position = player.global_position
	proj.setup(direction, _get_damage(), _get_area(), player.stats.piercing, _pool)
