## SpikeShoot.gd
## Shoots spikes in all directions from the player.
class_name SpikeShoot
extends WeaponBase

@export var spike_count: int = 4
@export var spike_speed: float = 400.0
@export var spike_pierce: int = 1

const level_ups_template = [
	{"damage": 1.5, "fire_rate": 1.2, "area": 1.2},
	{"damage": 2.0, "fire_rate": 1.4, "area": 1.4},
	{"damage": 2.5, "fire_rate": 1.6, "area": 1.6},
	{"damage": 3.0, "fire_rate": 1.8, "area": 1.8},
]

func _ready() -> void:
	weapon_id = "spike_shoot"
	base_damage = 15.0
	base_fire_rate = 1.5
	base_area = 1.0
	max_level = 5
	level_ups = level_ups_template
	super._ready()


func _fire() -> void:
	var count = spike_count
	if player and player.stats.projectile_count > 1:
		count = spike_count + int(player.stats.projectile_count - 1) * 2
	
	var angle_step = TAU / count
	for i in count:
		var angle = angle_step * i + randf() * 0.3
		_spawn_spike(angle)


func _spawn_spike(angle: float) -> void:
	var SpikeScene = load("res://scenes/gameplay/weapons/SpikeProjectile.tscn")
	var spike = SpikeScene.instantiate()
	spike.global_position = player.global_position
	spike.rotation = angle
	spike.speed = spike_speed
	spike.damage = _get_damage()
	spike.pierce = spike_pierce + (level - 1)
	spike.lifetime = 2.0
	spike.scale = Vector2.ONE * _get_area()
	get_tree().root.add_child(spike)
	EventBus.weapon_evolved.emit(weapon_id, level)