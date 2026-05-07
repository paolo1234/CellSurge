## ShotgunBlast.gd
## Fires a burst of projectiles in a cone.
class_name ShotgunBlast
extends WeaponBase

@export var pellets: int = 5
@export var spread_angle: float = 0.5  # radians

const level_ups_template = [
	{"damage": 1.4, "fire_rate": 1.3},
	{"damage": 1.7, "fire_rate": 1.4},
	{"damage": 2.0, "fire_rate": 1.5},
	{"damage": 2.3, "fire_rate": 1.6},
]

func _ready() -> void:
	weapon_id = "shotgun_blast"
	base_damage = 8.0
	base_fire_rate = 0.7
	base_area = 1.0
	max_level = 5
	level_ups = level_ups_template
	super._ready()


func _fire() -> void:
	var count = pellets + level
	var base_angle = player.stats.last_move_angle if "last_move_angle" in player else 0.0
	if base_angle == 0.0:
		base_angle = -PI / 2  # Default upward
	
	var angle_step = spread_angle / count
	for i in count:
		var angle = base_angle - spread_angle/2 + angle_step * i + randf_range(-0.1, 0.1)
		_spawn_pellet(angle)


func _spawn_pellet(angle: float) -> void:
	var ProjScene = load("res://scenes/gameplay/Projectile.tscn")
	var proj = ProjScene.instantiate()
	proj.global_position = player.global_position
	var dir = Vector2.from_angle(angle)
	proj.setup(dir, _get_damage(), _get_area() * 0.5, 1, null)
	proj.modulate = Color(1, 0.8, 0.2)  # Yellow shotgun pellets
	get_tree().root.add_child(proj)
	EventBus.weapon_evolved.emit(weapon_id, level)