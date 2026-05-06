## EnemyBase.gd
## Base class for all enemies.
class_name EnemyBase
extends CharacterBody2D

# ─── STATS (override per type) ────────────────────────────
@export var enemy_type: String = "enemy_base"
@export var max_health: float = 30.0
@export var move_speed: float = 80.0
@export var contact_damage: float = 10.0
@export var exp_value: float = 5.0
@export var damage_cooldown: float = 1.0

# ─── REFS ─────────────────────────────────────────────────
@onready var sprite: Sprite2D = $Sprite2D
@onready var collision: CollisionShape2D = $CollisionShape2D
@onready var damage_timer: Timer = $DamageTimer

# ─── STATE ────────────────────────────────────────────────
var current_health: float
var player: CharacterBody2D
var _flash_tween: Tween
var _can_damage: bool = true


func _ready() -> void:
	add_to_group("enemies")
	current_health = max_health
	player = get_tree().get_first_node_in_group("player")
	damage_timer.wait_time = damage_cooldown
	damage_timer.timeout.connect(_on_damage_timer_timeout)


func _physics_process(delta: float) -> void:
	if player == null:
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
	if global_position.distance_to(player.global_position) < 32.0:
		if player.has_method("take_damage"):
			player.take_damage(contact_damage)
			_can_damage = false
			damage_timer.start()


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
	EventBus.enemy_died.emit(enemy_type, global_position)
	_drop_exp()
	queue_free()


func _drop_exp() -> void:
	# World will handle spawning the orb via signal
	pass


func _flash_hit() -> void:
	if _flash_tween:
		_flash_tween.kill()
	sprite.modulate = Color.WHITE * 2.0
	_flash_tween = create_tween()
	_flash_tween.tween_property(sprite, "modulate", Color.WHITE, 0.1)
