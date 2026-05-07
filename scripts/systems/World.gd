func _process(delta: float) -> void:
	var bg = get_node_or_null("Background")
	if bg and is_instance_valid(camera):
		# Parallax - bg moves slower than camera
		var target_pos = camera.global_position * 0.3
		bg.global_position = bg.global_position.lerp(target_pos + Vector2(540, 480), 2.0 * delta)