## PlasmaOrbit.gd
## Orbs that orbit around the player, damaging enemies on contact.
## Creates orbs procedurally — no external scene needed.
class_name PlasmaOrbit
extends WeaponBase

var _orbs: Array = []
var _orbit_radius: float = 80.0
var _orbit_speed: float = 2.0
var _damage_cooldown: Dictionary = {}  # enemy_id -> time


func _ready() -> void:
	weapon_id = "plasma_orbit"
	base_damage = 12.0
	base_fire_rate = 0.5
	max_level = 5
	level_ups = [
		{"damage": 1.3, "area": 1.3, "fire_rate": 1.2},
		{"damage": 1.5, "area": 1.5, "fire_rate": 1.3},
		{"damage": 1.7, "area": 1.7, "fire_rate": 1.4},
		{"damage": 2.0, "area": 2.0, "fire_rate": 1.5},
	]
	super._ready()


func _process(delta: float) -> void:
	if player == null or player.is_dead:
		return
	_update_orbs(delta)
	_check_orb_damage(delta)


func _fire() -> void:
	_ensure_orb_count()


func _ensure_orb_count() -> void:
	var target_count: int = 3 + (level - 1)
	# Remove excess or invalid orbs
	var valid_orbs: Array = []
	for orb_data in _orbs:
		var orb: Node = orb_data.get("node")
		if orb and is_instance_valid(orb):
			valid_orbs.append(orb_data)
		elif orb and is_instance_valid(orb):
			orb.queue_free()
	_orbs = valid_orbs
	
	# Spawn missing orbs
	while _orbs.size() < target_count:
		var orb := _create_orb()
		var angle: float = (TAU / target_count) * _orbs.size()
		_orbs.append({
			"node": orb,
			"angle": angle,
			"speed": _orbit_speed * (1.0 + level * 0.1)
		})


func _create_orb() -> Area2D:
	var orb := Area2D.new()
	orb.collision_layer = 4  # Projectile layer
	orb.collision_mask = 2   # Enemy layer
	
	# Collision shape
	var shape := CircleShape2D.new()
	shape.radius = 12.0 * _get_area()
	var col := CollisionShape2D.new()
	col.shape = shape
	orb.add_child(col)
	
	# Visual — glowing circle drawn with Polygon2D
	var visual := Polygon2D.new()
	var points: PackedVector2Array = []
	var segments := 12
	var radius := 12.0 * _get_area()
	for i in segments:
		var angle := (TAU / segments) * i
		points.append(Vector2.from_angle(angle) * radius)
	visual.polygon = points
	visual.color = Color(0.3, 0.5, 1.0, 0.8)
	orb.add_child(visual)
	
	# Glow ring
	var glow := Polygon2D.new()
	var glow_points: PackedVector2Array = []
	var glow_radius := radius * 1.5
	for i in segments:
		var angle := (TAU / segments) * i
		glow_points.append(Vector2.from_angle(angle) * glow_radius)
	glow.polygon = glow_points
	glow.color = Color(0.2, 0.4, 1.0, 0.2)
	orb.add_child(glow)
	
	orb.z_index = 5
	get_tree().current_scene.add_child(orb)
	return orb


func _update_orbs(delta: float) -> void:
	if player == null or not is_instance_valid(player):
		return
	
	var to_remove: Array = []
	for i in range(_orbs.size()):
		var orb_data = _orbs[i]
		var orb: Node = orb_data.get("node")
		if orb == null or not is_instance_valid(orb):
			to_remove.append(i)
			continue
		orb_data["angle"] += orb_data["speed"] * delta
		var angle: float = orb_data["angle"]
		var radius: float = _orbit_radius * _get_area()
		var target_pos: Vector2 = player.global_position + Vector2.from_angle(angle) * radius
		orb.global_position = orb.global_position.lerp(target_pos, 8.0 * delta)
	
	# Remove invalid orbs (reverse order to keep indices valid)
	for i in range(to_remove.size() - 1, -1, -1):
		_orbs.remove_at(to_remove[i])


func _check_orb_damage(delta: float) -> void:
	# Update cooldowns
	var keys_to_remove := []
	for key in _damage_cooldown:
		_damage_cooldown[key] -= delta
		if _damage_cooldown[key] <= 0.0:
			keys_to_remove.append(key)
	for key in keys_to_remove:
		_damage_cooldown.erase(key)
	
	# Check each orb against enemies
	for orb_data in _orbs:
		var orb: Node = orb_data.get("node")
		if orb == null or not is_instance_valid(orb):
			continue
		var enemies := get_tree().get_nodes_in_group("enemies")
		for enemy in enemies:
			if not is_instance_valid(enemy):
				continue
			var dist: float = orb.global_position.distance_to(enemy.global_position)
			if dist < 30.0 * _get_area():
				var enemy_id := enemy.get_instance_id()
				if not _damage_cooldown.has(enemy_id):
					if enemy.has_method("take_damage"):
						enemy.take_damage(_get_damage())
					_damage_cooldown[enemy_id] = 0.5  # 0.5s cooldown per enemy


func _exit_tree() -> void:
	# Cleanup orbs when weapon is removed
	for orb_data in _orbs:
		var orb: Node = orb_data.get("node")
		if orb and is_instance_valid(orb):
			orb.queue_free()
	_orbs.clear()