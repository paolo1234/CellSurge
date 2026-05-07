## Splitter.gd
## Explodes into smaller enemies when killed.
class_name Splitter
extends EnemyBase

func _ready() -> void:
	enemy_type = "splitter"
	max_health = 40.0  # Tougher
	move_speed = 60.0
	contact_damage = 12.0
	exp_value = 15.0
	super._ready()


func _die() -> void:
	# Spawn 2-3 mini versions on death
	var mini_count = randi_range(2, 3)
	var spawner = get_tree().get_first_node_in_group("enemy_spawner")
	if spawner:
		for i in mini_count:
			_spawn_mini(spawner)
	super._die()


func _spawn_mini(spawner) -> void:
	var MiniScene = load("res://scenes/gameplay/enemies/MiniSplitter.tscn")
	var mini = MiniScene.instantiate()
	mini.global_position = global_position + Vector2(randf_range(-20, 20), randf_range(-20, 20))
	spawner.add_sibling(mini)