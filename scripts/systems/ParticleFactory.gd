## ParticleFactory.gd
## Creates procedural particle effects using GPUParticles2D.
## Usage: ParticleFactory.create_death_burst(Color.RED, position, parent)
class_name ParticleFactory
extends RefCounted


## Death burst: particles explode outward and fade
static func create_death_burst(color: Color, pos: Vector2, parent: Node) -> void:
	var particles := GPUParticles2D.new()
	particles.emitting = true
	particles.one_shot = true
	particles.amount = 12
	particles.lifetime = 0.6
	particles.explosiveness = 1.0
	particles.global_position = pos
	
	var mat := ParticleProcessMaterial.new()
	mat.direction = Vector3(0, 0, 0)
	mat.spread = 180.0
	mat.initial_velocity_min = 100.0
	mat.initial_velocity_max = 250.0
	mat.gravity = Vector3(0, 0, 0)
	mat.damping_min = 100.0
	mat.damping_max = 200.0
	mat.scale_min = 3.0
	mat.scale_max = 8.0
	mat.scale_over_velocity_min = 0.0
	mat.color = color
	
	# Fade out
	var gradient := Gradient.new()
	gradient.set_color(0, color)
	gradient.set_color(1, Color(color.r, color.g, color.b, 0.0))
	var grad_tex := GradientTexture1D.new()
	grad_tex.gradient = gradient
	mat.color_ramp = grad_tex
	
	particles.process_material = mat
	parent.add_child(particles)
	
	# Auto-cleanup
	_auto_free(particles, 1.0)


## Hit spark: quick bright flash at impact point
static func create_hit_spark(pos: Vector2, parent: Node) -> void:
	var particles := GPUParticles2D.new()
	particles.emitting = true
	particles.one_shot = true
	particles.amount = 6
	particles.lifetime = 0.25
	particles.explosiveness = 1.0
	particles.global_position = pos
	
	var mat := ParticleProcessMaterial.new()
	mat.direction = Vector3(0, 0, 0)
	mat.spread = 180.0
	mat.initial_velocity_min = 60.0
	mat.initial_velocity_max = 150.0
	mat.gravity = Vector3(0, 0, 0)
	mat.damping_min = 200.0
	mat.damping_max = 300.0
	mat.scale_min = 2.0
	mat.scale_max = 5.0
	mat.color = Color(1.0, 0.9, 0.3, 1.0)  # Bright yellow
	
	var gradient := Gradient.new()
	gradient.set_color(0, Color(1.0, 1.0, 0.6, 1.0))
	gradient.set_color(1, Color(1.0, 0.5, 0.0, 0.0))
	var grad_tex := GradientTexture1D.new()
	grad_tex.gradient = gradient
	mat.color_ramp = grad_tex
	
	particles.process_material = mat
	parent.add_child(particles)
	_auto_free(particles, 0.5)


## Level up ring: expanding golden ring effect
static func create_levelup_effect(pos: Vector2, parent: Node) -> void:
	# Rising particles
	var particles := GPUParticles2D.new()
	particles.emitting = true
	particles.one_shot = true
	particles.amount = 20
	particles.lifetime = 1.0
	particles.explosiveness = 0.8
	particles.global_position = pos
	
	var mat := ParticleProcessMaterial.new()
	mat.direction = Vector3(0, -1, 0)
	mat.spread = 60.0
	mat.initial_velocity_min = 80.0
	mat.initial_velocity_max = 200.0
	mat.gravity = Vector3(0, -50, 0)
	mat.scale_min = 2.0
	mat.scale_max = 5.0
	mat.color = Color(1.0, 0.84, 0.0, 1.0)  # Gold
	
	var gradient := Gradient.new()
	gradient.set_color(0, Color(1.0, 0.9, 0.2, 1.0))
	gradient.set_color(1, Color(1.0, 0.6, 0.0, 0.0))
	var grad_tex := GradientTexture1D.new()
	grad_tex.gradient = gradient
	mat.color_ramp = grad_tex
	
	particles.process_material = mat
	parent.add_child(particles)
	_auto_free(particles, 1.5)


## Heal effect: green rising particles
static func create_heal_effect(pos: Vector2, parent: Node) -> void:
	var particles := GPUParticles2D.new()
	particles.emitting = true
	particles.one_shot = true
	particles.amount = 8
	particles.lifetime = 0.8
	particles.explosiveness = 0.5
	particles.global_position = pos
	
	var mat := ParticleProcessMaterial.new()
	mat.direction = Vector3(0, -1, 0)
	mat.spread = 30.0
	mat.initial_velocity_min = 40.0
	mat.initial_velocity_max = 100.0
	mat.gravity = Vector3(0, -20, 0)
	mat.scale_min = 2.0
	mat.scale_max = 4.0
	mat.color = Color(0.2, 1.0, 0.1, 1.0)  # Green
	
	var gradient := Gradient.new()
	gradient.set_color(0, Color(0.2, 1.0, 0.3, 1.0))
	gradient.set_color(1, Color(0.1, 0.8, 0.2, 0.0))
	var grad_tex := GradientTexture1D.new()
	grad_tex.gradient = gradient
	mat.color_ramp = grad_tex
	
	particles.process_material = mat
	parent.add_child(particles)
	_auto_free(particles, 1.2)


## Pickup flash: quick cyan flash
static func create_pickup_effect(pos: Vector2, parent: Node) -> void:
	var particles := GPUParticles2D.new()
	particles.emitting = true
	particles.one_shot = true
	particles.amount = 5
	particles.lifetime = 0.3
	particles.explosiveness = 1.0
	particles.global_position = pos
	
	var mat := ParticleProcessMaterial.new()
	mat.direction = Vector3(0, -1, 0)
	mat.spread = 180.0
	mat.initial_velocity_min = 30.0
	mat.initial_velocity_max = 80.0
	mat.gravity = Vector3(0, 0, 0)
	mat.scale_min = 2.0
	mat.scale_max = 4.0
	mat.color = Color(0.0, 1.0, 1.0, 1.0)  # Cyan
	
	particles.process_material = mat
	parent.add_child(particles)
	_auto_free(particles, 0.6)


## Boss warning: screen edge pulse (added as child of CanvasLayer)
static func create_boss_warning(parent: Node) -> void:
	var rect := ColorRect.new()
	rect.color = Color(1.0, 0.0, 0.0, 0.0)
	rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(rect)
	
	var tween := rect.create_tween()
	tween.set_loops(3)
	tween.tween_property(rect, "color:a", 0.25, 0.3)
	tween.tween_property(rect, "color:a", 0.0, 0.3)
	tween.finished.connect(rect.queue_free)


## Victory celebration: golden particles everywhere
static func create_victory_burst(pos: Vector2, parent: Node) -> void:
	for i in 3:
		var particles := GPUParticles2D.new()
		particles.emitting = true
		particles.one_shot = true
		particles.amount = 30
		particles.lifetime = 2.0
		particles.explosiveness = 0.6
		particles.global_position = pos + Vector2(randf_range(-100, 100), randf_range(-100, 100))
		
		var mat := ParticleProcessMaterial.new()
		mat.direction = Vector3(0, -1, 0)
		mat.spread = 180.0
		mat.initial_velocity_min = 100.0
		mat.initial_velocity_max = 300.0
		mat.gravity = Vector3(0, 200, 0)
		mat.scale_min = 2.0
		mat.scale_max = 6.0
		
		var colors := [Color(1, 0.84, 0), Color(0, 1, 1), Color(0.2, 1, 0.1)]
		mat.color = colors[i % colors.size()]
		
		var gradient := Gradient.new()
		gradient.set_color(0, mat.color)
		gradient.set_color(1, Color(mat.color.r, mat.color.g, mat.color.b, 0.0))
		var grad_tex := GradientTexture1D.new()
		grad_tex.gradient = gradient
		mat.color_ramp = grad_tex
		
		particles.process_material = mat
		parent.add_child(particles)
		_auto_free(particles, 3.0)


static func _auto_free(node: Node, delay: float) -> void:
	var timer := node.get_tree().create_timer(delay)
	timer.timeout.connect(func():
		if is_instance_valid(node):
			node.queue_free()
	)
