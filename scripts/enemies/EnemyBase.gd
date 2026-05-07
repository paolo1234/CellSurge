## EnemyBase.gd
## Base class for all enemies.
class_name EnemyBase
extends CharacterBody2D

# ─── STATS (override per type) ────────────────────────────
@export var enemy_type: String = "enemy_base"
@export var max_health: float = 30.0
@export var base_max_health: float = 30.0
@export var move_speed: float = 80.0
@export var contact_damage: float = 10.0
@export var base_contact_damage: float = 10.0
@export var exp_value: float = 5.0
@export var damage_cooldown: float = 1.0

# ─── REFS ─────────────────────────────────────────────────
@onready var sprite: Polygon2D = $Sprite2D
@onready var collision: CollisionShape2D = $CollisionShape2D
@onready var damage_timer: Timer = $DamageTimer

# ─── STATE ────────────────────────────────────────────────
var current_health: float
var player: CharacterBody2D
var _flash_tween: Tween
var _can_damage: bool = true

# Scaling da WaveManager
var _hp_mult: float = 1.0
var _dmg_mult: float = 1.0


func _ready() -> void:
	add_to_group("enemies")
	base_max_health = max_health
	base_contact_damage = contact_damage
	current_health = max_health
	player = get_tree().get_first_node_in_group("player")
	damage_timer.wait_time = damage_cooldown
	damage_timer.timeout.connect(_on_damage_timer_timeout)


func apply_scaling(hp_mult: float, dmg_mult: float) -> void:
	_hp_mult = hp_mult
	_dmg_mult = dmg_mult
	max_health = base_max_health * hp_mult
	current_health = max_health
	contact_damage = base_contact_damage * dmg_mult
	move_speed *= (1.0 + (hp_mult - 1.0) * 0.1)  # slight speed increase with HP


func _physics_process(delta: float) -> void:
	if player == null or not is_instance_valid(player):
		player = get_tree().get_first_node_in_group("player")
		return
	_move_toward_player(delta)
	_check_player_contact()


func _move_toward_player(_delta: float) -> void:
	var dir := (player.global_position - global_position).normalized()
	velocity = dir * move_speed
	move_and_slide()


func _check_player_contact() -> void:
	if not _can_damage:
		return
	if player == null or not is_instance_valid(player):
		return
	
	for i in get_slide_collision_count():
		var collision := get_slide_collision(i)
		var collider := collision.get_collider()
		if collider == player:
			if collider.has_method("take_damage"):
				collider.take_damage(contact_damage)
				_can_damage = false
				damage_timer.start()
			return


func _on_damage_timer_timeout() -> void:
	_can_damage = true


# ─── DAMAGE / DEATH ───────────────────────────────────────
func take_damage(amount: float) -> void:
	current_health -= amount
	EventBus.show_floating_text.emit(str(int(amount)), global_position, Color.YELLOW)
	GameManager.register_damage(amount)
	_flash_hit()
	if current_health <= 0.0:
		_die()


func _die() -> void:
	remove_from_group("enemies")
	_spawn_death_effect()
	EventBus.enemy_died.emit(enemy_type, global_position)
	_drop_exp()
	call_deferred("queue_free")


func _spawn_death_effect() -> void:
	for i in 6:
		var particle = ColorRect.new()
		particle.color = _get_enemy_color()
		particle.custom_minimum_size = Vector2(randf_range(4, 10), randf_range(4, 10))
		particle.global_position = global_position
		get_tree().root.add_child(particle)
		
		var dir = Vector2.from_angle(randf() * TAU)
		var tween = create_tween()
		tween.set_parallel(true)
		tween.tween_property(particle, "global_position", global_position + dir * randf_range(30, 80), 0.3)
		tween.tween_property(particle, "modulate:a", 0.0, 0.3)
		tween.tween_property(particle, "size", Vector2.ZERO, 0.3)
		await tween.finished
		particle.queue_free()


func _get_enemy_color() -> Color:
	match enemy_type:
		"batterio": return Color(0.9, 0.2, 0.2)
		"virus": return Color(0.3, 0.9, 0.3)
		"fungo": return Color(0.7, 0.3, 0.8)
		"leech": return Color(0.8, 0.2, 0.5)
		"ranged_cell": return Color(1.0, 0.5, 0.0)
		"splitter": return Color(0.9, 0.9, 0.3)
		_: return Color(0.8, 0.8, 0.8)


func _drop_exp() -> void:
	var orb_scene := load("res://scenes/gameplay/ExpOrb.tscn")
	var orb = orb_scene.instantiate()
	orb.global_position = global_position
	call_deferred("add_sibling", orb)
	if orb.has_method("setup"):
		orb.setup(exp_value)


func _flash_hit() -> void:
	if _flash_tween:
		_flash_tween.kill()
	sprite.color = Color(2, 2, 2, 1)
	_flash_tween = create_tween()
	_flash_tween.tween_property(sprite, "color", Color(0.9, 0.2, 0.2, 1), 0.1)