## Player.gd
## Handles movement, health, damage, death and component wiring.
class_name Player
extends CharacterBody2D

# ─── REFERENCES ───────────────────────────────────────────
@onready var sprite: Polygon2D = $Sprite2D
@onready var collision: CollisionShape2D = $CollisionShape2D
@onready var weapon_container: Node2D = $Weapons
@onready var pickup_area: Area2D = $PickupArea
@onready var invincibility_timer: Timer = $InvincibilityTimer

# ─── STATS ────────────────────────────────────────────────
var stats: PlayerStats
var current_health: float
var is_dead: bool = false
var is_invincible: bool = false

# ─── MOVEMENT TRACKING ───────────────────────────────────
var last_move_direction: Vector2 = Vector2.DOWN
var last_move_angle: float = -PI / 2  # Default up

# ─── WEAPONS ──────────────────────────────────────────────
var weapons: Array = []

# ─── SPEED BOOST (from upgrades) ─────────────────────────
var _speed_boost_timer: float = 0.0
var _speed_boost_active: bool = false

# ─── HIT FLASH ────────────────────────────────────────────
var _flash_tween: Tween


func _ready() -> void:
	add_to_group("player")
	stats = PlayerStats.new()
	stats.apply_meta_upgrades()
	current_health = stats.max_health
	# Connect invincibility timer properly
	invincibility_timer.timeout.connect(_on_invincibility_timer_timeout)
	_setup_pickup_area()
	# Add starting weapon
	add_weapon(load("res://scripts/player/weapons/NucleusPulse.gd"))
	GameManager.start_run()
	# Connect enemy death for speed boost and lifesteal tracking
	EventBus.enemy_died.connect(_on_enemy_killed)


func _physics_process(delta: float) -> void:
	if is_dead:
		return
	_process_movement(delta)
	_process_regen(delta)
	_process_speed_boost(delta)


func _process_movement(_delta: float) -> void:
	var input_vec := Vector2.ZERO

	# Mobile joystick (set externally by VirtualJoystick)
	if has_meta("joystick_input"):
		input_vec = get_meta("joystick_input")
	else:
		# Keyboard fallback for testing
		input_vec.x = Input.get_axis("move_left", "move_right")
		input_vec.y = Input.get_axis("move_up", "move_down")

	if input_vec.length() > 1.0:
		input_vec = input_vec.normalized()

	# Track direction for weapons like ShotgunBlast
	if input_vec.length() > 0.1:
		last_move_direction = input_vec.normalized()
		last_move_angle = last_move_direction.angle()

	var speed := stats.move_speed
	if _speed_boost_active:
		speed *= (1.0 + stats.speed_boost)

	velocity = input_vec * speed
	move_and_slide()


func _process_regen(delta: float) -> void:
	if stats.regen > 0 and current_health < stats.max_health:
		heal(stats.regen * delta)


func _process_speed_boost(delta: float) -> void:
	if _speed_boost_active:
		_speed_boost_timer -= delta
		if _speed_boost_timer <= 0.0:
			_speed_boost_active = false


func _setup_pickup_area() -> void:
	var shape := CircleShape2D.new()
	shape.radius = stats.pickup_radius
	var collision_pickup := CollisionShape2D.new()
	collision_pickup.shape = shape
	pickup_area.add_child(collision_pickup)
	pickup_area.area_entered.connect(_on_pickup_area_entered)


# ─── HEALTH ───────────────────────────────────────────────
func take_damage(amount: float) -> void:
	if is_dead or is_invincible:
		return
	var actual := stats.calculate_incoming_damage(amount)
	if actual <= 0.0:
		# Dodged!
		EventBus.show_floating_text.emit("SCHIVATO!", global_position, Color(0.5, 0.8, 1.0))
		return
	current_health -= actual
	current_health = clampf(current_health, 0.0, stats.max_health)
	EventBus.player_damaged.emit(actual, current_health)
	_flash_hit()
	_start_invincibility()
	EventBus.screen_shake_requested.emit(3.0, 0.15)
	AudioManager.play_damage()
	# Thorns — damage the attacker
	# (handled at enemy contact level, not here)
	if current_health <= 0.0:
		_die()


func heal(amount: float) -> void:
	if is_dead:
		return
	var old_health := current_health
	current_health = minf(current_health + amount, stats.max_health)
	if current_health > old_health:
		EventBus.player_healed.emit(amount, current_health)


func apply_lifesteal(damage_dealt: float) -> void:
	if stats.lifesteal > 0.0:
		var heal_amount := damage_dealt * stats.lifesteal
		heal(heal_amount)


# ─── DEATH ────────────────────────────────────────────────
func _die() -> void:
	is_dead = true
	set_physics_process(false)
	# Disable collisions
	collision.set_deferred("disabled", true)
	EventBus.player_died.emit()
	AudioManager.play_death()
	# Death particles
	ParticleFactory.create_death_burst(Color(0.2, 0.8, 1.0), global_position, get_parent())
	# Death animation
	var tween := create_tween()
	tween.tween_property(sprite, "color", Color(0, 0, 0, 0), 0.5)
	await tween.finished
	queue_free()


# ─── HIT FEEDBACK ─────────────────────────────────────────
func _flash_hit() -> void:
	if _flash_tween:
		_flash_tween.kill()
	sprite.color = Color(1.5, 0.3, 0.3)
	_flash_tween = create_tween()
	_flash_tween.tween_property(sprite, "color", Color(0.2, 0.8, 1, 1), 0.15)


func _start_invincibility() -> void:
	is_invincible = true
	invincibility_timer.start(0.6)


func _on_invincibility_timer_timeout() -> void:
	is_invincible = false


# ─── PICKUP ───────────────────────────────────────────────
func _on_pickup_area_entered(area: Area2D) -> void:
	if area.is_in_group("exp_orb"):
		area.attract(global_position)


# ─── ENEMY KILLED (for speed boost) ──────────────────────
func _on_enemy_killed(_type: String, _pos: Vector2) -> void:
	if stats.speed_boost > 0.0:
		_speed_boost_active = true
		_speed_boost_timer = 3.0  # 3 seconds of speed boost


# ─── WEAPON API (called by UpgradeSystem) ─────────────────
func add_weapon(weapon_or_script) -> void:
	var w: Node
	if weapon_or_script is PackedScene:
		w = weapon_or_script.instantiate()
	elif weapon_or_script is Script:
		w = weapon_or_script.new()
	else:
		return
	w.player = self
	weapon_container.add_child(w)
	weapons.append(w)


func get_nearest_enemy() -> Node2D:
	var enemies := get_tree().get_nodes_in_group("enemies")
	var nearest: Node2D = null
	var min_dist := INF
	for e in enemies:
		var d := global_position.distance_to(e.global_position)
		if d < min_dist:
			min_dist = d
			nearest = e
	return nearest