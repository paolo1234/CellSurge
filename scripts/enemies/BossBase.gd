## BossBase.gd
## Boss enemy with HP bar, phases, and mini-enemy spawning.
## Created procedurally by WaveManager — no scene file needed.
class_name BossBase
extends CharacterBody2D

@export var boss_id: String = "boss"
@export var max_health: float = 2000.0
@export var base_max_health: float = 2000.0
@export var move_speed: float = 60.0
@export var contact_damage: float = 25.0
@export var base_contact_damage: float = 25.0
@export var exp_value: float = 100.0
@export var damage_cooldown: float = 0.8

var current_health: float
var player: CharacterBody2D
var _can_damage: bool = true
var _flash_tween: Tween
var _phase: int = 1
var _spawn_timer: float = 0.0
var _attack_timer: float = 0.0
var _visual: Polygon2D
var _glow: Polygon2D

func _ready() -> void:
	add_to_group("enemies")
	current_health = max_health
	player = get_tree().get_first_node_in_group("player")
	_setup_visual()
	_setup_collision()
	_setup_damage_timer()

func _setup_visual() -> void:
	# Big boss polygon
	_visual = Polygon2D.new()
	_visual.name = "Sprite2D"
	var points: PackedVector2Array = []
	var segments := 16
	var radius := 40.0
	for i in segments:
		var angle := (TAU / segments) * i
		var r := radius + sin(angle * 3) * 8.0  # Irregular shape
		points.append(Vector2.from_angle(angle) * r)
	_visual.polygon = points
	_visual.color = _get_boss_color()
	add_child(_visual)
	# Glow ring
	_glow = Polygon2D.new()
	var glow_points: PackedVector2Array = []
	for i in segments:
		var angle := (TAU / segments) * i
		glow_points.append(Vector2.from_angle(angle) * (radius + 15))
	_glow.polygon = glow_points
	_glow.color = _get_boss_color() * Color(1, 1, 1, 0.2)
	add_child(_glow)

func _setup_collision() -> void:
	var col := CollisionShape2D.new()
	col.name = "CollisionShape2D"
	var shape := CircleShape2D.new()
	shape.radius = 35.0
	col.shape = shape
	add_child(col)
	collision_layer = 2  # Enemy
	collision_mask = 1 | 4  # Player + Projectile

func _setup_damage_timer() -> void:
	var timer := Timer.new()
	timer.name = "DamageTimer"
	timer.one_shot = true
	timer.wait_time = damage_cooldown
	timer.timeout.connect(func(): _can_damage = true)
	add_child(timer)

func _physics_process(delta: float) -> void:
	if player == null or not is_instance_valid(player):
		player = get_tree().get_first_node_in_group("player")
		return
	_update_phase()
	_move(delta)
	_check_contact()
	_spawn_minions(delta)
	_boss_attack(delta)
	# Pulse glow
	if _glow:
		_glow.color.a = 0.15 + sin(Time.get_ticks_msec() * 0.003) * 0.1
	# Report HP
	EventBus.boss_hp_changed.emit(current_health, max_health)

func _update_phase() -> void:
	var hp_pct := current_health / max_health
	if hp_pct <= 0.25:
		_phase = 3
		move_speed = 90.0
	elif hp_pct <= 0.5:
		_phase = 2
		move_speed = 75.0
	else:
		_phase = 1
		move_speed = 60.0

func _move(delta: float) -> void:
	var dir := (player.global_position - global_position).normalized()
	# Phase 2+: circular movement
	if _phase >= 2:
		var perp := Vector2(-dir.y, dir.x)
		dir = (dir + perp * sin(Time.get_ticks_msec() * 0.002) * 0.5).normalized()
	velocity = dir * move_speed
	move_and_slide()

func _check_contact() -> void:
	if not _can_damage or player == null or not is_instance_valid(player):
		return
	for i in get_slide_collision_count():
		var col := get_slide_collision(i)
		if col.get_collider() == player:
			if player.has_method("take_damage"):
				player.take_damage(contact_damage)
				_can_damage = false
				$DamageTimer.start()
			return

func _spawn_minions(delta: float) -> void:
	_spawn_timer -= delta
	if _spawn_timer <= 0.0:
		_spawn_timer = 5.0 - _phase  # Faster spawning in later phases
		var bat_scene = load("res://scenes/gameplay/enemies/Batterio.tscn")
		if bat_scene:
			for i in _phase:
				var minion = bat_scene.instantiate()
				var offset := Vector2.from_angle(randf() * TAU) * 60
				minion.global_position = global_position + offset
				get_parent().call_deferred("add_child", minion)

func _boss_attack(delta: float) -> void:
	_attack_timer -= delta
	if _attack_timer <= 0.0:
		_attack_timer = 3.0 / _phase
		# Shoot projectiles in ring
		_shoot_ring()

func _shoot_ring() -> void:
	var proj_scene = load("res://scenes/gameplay/Projectile.tscn")
	if not proj_scene:
		return
	var count := 4 + _phase * 2
	for i in count:
		var angle := (TAU / count) * i
		var proj = proj_scene.instantiate()
		proj.global_position = global_position
		var dir := Vector2.from_angle(angle)
		proj.setup(dir, contact_damage * 0.5, 1.5, 0, null)
		proj.modulate = Color(1, 0.2, 0.1)
		# Override collision to hit player
		proj.collision_layer = 2  # Enemy
		proj.collision_mask = 1   # Player
		get_parent().call_deferred("add_child", proj)

func take_damage(amount: float) -> void:
	current_health -= amount
	EventBus.show_floating_text.emit(str(int(amount)), global_position, Color.YELLOW)
	GameManager.register_damage(amount)
	_flash_hit()
	AudioManager.play_hit()
	if player and is_instance_valid(player) and player.has_method("apply_lifesteal"):
		player.apply_lifesteal(amount)
	if current_health <= 0.0:
		_die()

func _die() -> void:
	remove_from_group("enemies")
	ParticleFactory.create_death_burst(_get_boss_color(), global_position, get_parent())
	ParticleFactory.create_death_burst(_get_boss_color().lightened(0.3), global_position, get_parent())
	AudioManager.play_death()
	EventBus.boss_died.emit(boss_id)
	EventBus.enemy_died.emit(boss_id, global_position)
	EventBus.screen_shake_requested.emit(12.0, 0.6)
	# Drop lots of exp
	var orb_scene := load("res://scenes/gameplay/ExpOrb.tscn")
	for i in 10:
		var orb = orb_scene.instantiate()
		orb.global_position = global_position + Vector2(randf_range(-50, 50), randf_range(-50, 50))
		call_deferred("add_sibling", orb)
		if orb.has_method("setup"):
			orb.setup(exp_value / 5.0)
	call_deferred("queue_free")

func _flash_hit() -> void:
	if _flash_tween:
		_flash_tween.kill()
	if _visual:
		_visual.color = Color(2, 2, 2, 1)
		_flash_tween = create_tween()
		_flash_tween.tween_property(_visual, "color", _get_boss_color(), 0.1)

func _get_boss_color() -> Color:
	match boss_id:
		"super_cellula": return Color(1.0, 0.3, 0.1)
		"prione": return Color(0.6, 0.1, 0.8)
		_: return Color(0.8, 0.2, 0.2)
