## EnemyBase.gd
## Base class for all enemies. Uses ParticleFactory for death effects.
class_name EnemyBase
extends CharacterBody2D

@export var enemy_type: String = "enemy_base"
@export var max_health: float = 30.0
@export var base_max_health: float = 30.0
@export var move_speed: float = 80.0
@export var contact_damage: float = 10.0
@export var base_contact_damage: float = 10.0
@export var exp_value: float = 5.0
@export var damage_cooldown: float = 1.0

var current_health: float
var player: CharacterBody2D
var _flash_tween: Tween
var _can_damage: bool = true
var _hp_mult: float = 1.0
var _dmg_mult: float = 1.0
var _sprite: Polygon2D
var _damage_timer: Timer

func _ready() -> void:
	add_to_group("enemies")
	_sprite = get_node_or_null("Sprite2D") as Polygon2D
	_damage_timer = get_node_or_null("DamageTimer") as Timer
	if _damage_timer == null:
		_damage_timer = Timer.new()
		_damage_timer.name = "DamageTimer"
		_damage_timer.one_shot = true
		add_child(_damage_timer)
	base_max_health = max_health
	base_contact_damage = contact_damage
	current_health = max_health
	player = get_tree().get_first_node_in_group("player")
	_damage_timer.wait_time = damage_cooldown
	_damage_timer.timeout.connect(_on_damage_timer_timeout)

func apply_scaling(hp_mult: float, dmg_mult: float) -> void:
	_hp_mult = hp_mult
	_dmg_mult = dmg_mult
	max_health = base_max_health * hp_mult
	current_health = max_health
	contact_damage = base_contact_damage * dmg_mult
	move_speed *= (1.0 + (hp_mult - 1.0) * 0.1)

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
	if not _can_damage or player == null or not is_instance_valid(player):
		return
	for i in get_slide_collision_count():
		var col := get_slide_collision(i)
		var collider := col.get_collider()
		if collider == player:
			if collider.has_method("take_damage"):
				collider.take_damage(contact_damage)
				# Thorns damage
				if player.has_method("get") and player.get("stats") != null:
					var stats = player.stats
					if stats.thorns > 0:
						take_damage(stats.thorns)
				_can_damage = false
				_damage_timer.start()
			return

func _on_damage_timer_timeout() -> void:
	_can_damage = true

func take_damage(amount: float) -> void:
	current_health -= amount
	EventBus.show_floating_text.emit(str(int(amount)), global_position, Color.YELLOW)
	GameManager.register_damage(amount)
	_flash_hit()
	AudioManager.play_hit()
	# Lifesteal for player
	if player and is_instance_valid(player) and player.has_method("apply_lifesteal"):
		player.apply_lifesteal(amount)
	if current_health <= 0.0:
		_die()

func _die() -> void:
	remove_from_group("enemies")
	ParticleFactory.create_death_burst(_get_enemy_color(), global_position, get_parent())
	AudioManager.play_death()
	EventBus.enemy_died.emit(enemy_type, global_position)
	_drop_exp()
	call_deferred("queue_free")

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
	if orb_scene == null:
		return
	var orb = orb_scene.instantiate()
	orb.global_position = global_position
	call_deferred("add_sibling", orb)
	if orb.has_method("setup"):
		orb.setup(exp_value)

func _flash_hit() -> void:
	if _sprite == null:
		return
	if _flash_tween:
		_flash_tween.kill()
	_sprite.color = Color(2, 2, 2, 1)
	_flash_tween = create_tween()
	_flash_tween.tween_property(_sprite, "color", _get_enemy_color(), 0.1)