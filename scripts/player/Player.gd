## Player.gd
## Handles movement, health, damage, death and component wiring.
class_name Player
extends CharacterBody2D

# ─── REFERENCES ───────────────────────────────────────────
@onready var sprite: Sprite2D = $Sprite2D
@onready var collision: CollisionShape2D = $CollisionShape2D
@onready var weapon_container: Node2D = $Weapons
@onready var pickup_area: Area2D = $PickupArea
@onready var invincibility_timer: Timer = $InvincibilityTimer

# ─── STATS ────────────────────────────────────────────────
var stats: PlayerStats
var current_health: float
var is_dead: bool = false
var is_invincible: bool = false

# ─── WEAPONS ──────────────────────────────────────────────
var weapons: Array = []

# ─── HIT FLASH ────────────────────────────────────────────
var _flash_tween: Tween


func _ready() -> void:
	stats = PlayerStats.new()
	stats.apply_meta_upgrades()
	current_health = stats.max_health
	_setup_pickup_area()
	GameManager.start_run()


func _physics_process(delta: float) -> void:
	if is_dead:
		return
	_process_movement(delta)
	_process_regen(delta)


func _process_movement(delta: float) -> void:
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

	velocity = input_vec * stats.move_speed
	move_and_slide()


func _process_regen(delta: float) -> void:
	if stats.regen > 0 and current_health < stats.max_health:
		heal(stats.regen * delta)


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
	current_health -= actual
	current_health = clampf(current_health, 0.0, stats.max_health)
	EventBus.player_damaged.emit(actual, current_health)
	_flash_hit()
	_start_invincibility()
	EventBus.screen_shake_requested.emit(3.0, 0.15)
	if current_health <= 0.0:
		_die()


func heal(amount: float) -> void:
	if is_dead:
		return
	current_health = minf(current_health + amount, stats.max_health)
	EventBus.player_healed.emit(amount, current_health)


# ─── DEATH ────────────────────────────────────────────────
func _die() -> void:
	is_dead = true
	set_physics_process(false)
	# Disable collisions
	collision.set_deferred("disabled", true)
	EventBus.player_died.emit()
	# Death animation
	var tween := create_tween()
	tween.tween_property(sprite, "modulate:a", 0.0, 0.5)
	await tween.finished
	queue_free()


# ─── HIT FEEDBACK ─────────────────────────────────────────
func _flash_hit() -> void:
	if _flash_tween:
		_flash_tween.kill()
	sprite.modulate = Color(1.5, 0.3, 0.3)
	_flash_tween = create_tween()
	_flash_tween.tween_property(sprite, "modulate", Color.WHITE, 0.15)


func _start_invincibility() -> void:
	is_invincible = true
	invincibility_timer.start(0.6)


func _on_InvincibilityTimer_timeout() -> void:
	is_invincible = false


# ─── PICKUP ───────────────────────────────────────────────
func _on_pickup_area_entered(area: Area2D) -> void:
	if area.is_in_group("exp_orb"):
		area.attract(global_position)


# ─── WEAPON API (called by UpgradeSystem) ─────────────────
func add_weapon(weapon_scene: PackedScene) -> void:
	var w := weapon_scene.instantiate()
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
