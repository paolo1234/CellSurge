## ObjectPool.gd
## Generic object pool. Pre-instantiates scenes and recycles them.
## Usage:
##   var pool = ObjectPool.new(preload("res://scenes/fx/ExpOrb.tscn"), 50, parent_node)
##   var orb = pool.get()   # get an inactive instance
##   pool.release(orb)      # return it to pool
class_name ObjectPool
extends RefCounted

var _scene: PackedScene
var _pool: Array[Node] = []
var _parent: Node


func _init(scene: PackedScene, initial_size: int, parent: Node) -> void:
	_scene = scene
	_parent = parent
	for i in initial_size:
		var inst := _scene.instantiate()
		inst.process_mode = Node.PROCESS_MODE_DISABLED
		inst.hide()
		_parent.add_child(inst)
		_pool.append(inst)


func get() -> Node:
	for node in _pool:
		if not node.visible:
			node.show()
			node.process_mode = Node.PROCESS_MODE_INHERIT
			return node
	# Pool exhausted — grow it
	var inst := _scene.instantiate()
	_parent.add_child(inst)
	_pool.append(inst)
	return inst


func release(node: Node) -> void:
	node.hide()
	node.process_mode = Node.PROCESS_MODE_DISABLED
	# Reset position to avoid stale positions
	if node.has_method("reset"):
		node.reset()
