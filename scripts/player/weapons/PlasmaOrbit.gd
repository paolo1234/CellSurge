## PlasmaOrbit.gd
## Orbs that orbit around the player, damaging enemies on contact.
class_name PlasmaOrbit
extends WeaponBase

var _orbs: Array = []
var _orbit_radius: float = 80.0
var _orbit_speed: float = 2.0

const level_ups_template := [
	{"damage": 1.3, "area": 1.3, "fire_rate": 1.2},
	{"damage": 1.5, "area": 1.5, "fire_rate": 1.3},
	{"damage": 1.7, "area": 1.7, "fire_rate": 1.4},
	{"damage": 2.0, "area": 2.0, "fire_rate": 1.5},
]

func _ready() -> void:
	weapon_id = "plasma_orbit"
	base_damage = 12.0
	base_fire_rate = 0.5
	max_level = 5
	level_ups = level_ups_template
	super._ready()


func _process(delta: float) -> void:
	if player == null or player.is_dead:
		return
	_update_orbs(delta)


func _fire() -> void:
	_spawn_orbs(3 + (level - 1))


func _spawn_orbs(count: int) -> void:
	var total = 3 + level
	for i in total:
		if _orbs.size() >= total:
			break
		var OrbScene = load("res://scenes/gameplay/weapons/OrbProjectile.tscn")
		var orb = OrbScene.instantiate()
		orb.global_position = player.global_position
		orb.damage = _get_damage() * 0.5
		orb.lifetime = 10.0
		orb.scale = Vector2.ONE * _get_area()
		get_tree().root.add_child(orb)
		_orbs.append({
			"node": orb,
			"angle": (TAU / total) * i,
			"speed": _orbit_speed * (1.0 + level * 0.1)
		})
	EventBus.weapon_evolved.emit(weapon_id, level)


func _update_orbs(delta: float) -> void:
	if player == null or not is_instance_valid(player):
		return
	
	var to_remove: Array = []
	for i in range(_orbs.size()):
		var orb_data = _orbs[i]
		var orb = orb_data.get("node")
		if orb == null or not is_instance_valid(orb):
			to_remove.append(i)
			continue
		orb_data["angle"] += orb_data["speed"] * delta
		var angle = orb_data["angle"]
		var radius = _orbit_radius * _get_area()
		var target_pos = player.global_position + Vector2.from_angle(angle) * radius
		orb.global_position = orb.global_position.lerp(target_pos, 5.0 * delta)
	
	# Remove invalid orbs
	for i in to_remove:
		var orb = _orbs[i].get("node")
		if orb and is_instance_valid(orb):
			orb.queue_free()
		_orbs.remove_at(i)