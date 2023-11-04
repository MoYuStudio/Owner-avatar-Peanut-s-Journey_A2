
extends PanelContainer

var node1 = null

func _get_drag_data(at_position):
	if has_node("Sprite"):
		var texture = TextureRect.new()
		texture.texture = $Sprite.texture
		texture.scale = $Sprite.scale
		texture.texture_filter = 1
		set_drag_preview(texture)
		node1 = $Sprite
		return $Sprite
	return true
	pass
	
func _can_drop_data(at_position, data):
	return true
	pass

func _drop_data(at_position,data):
	var node2 = self
	if data and !has_node("Sprite"):
		var new_sprite = data.duplicate()
		new_sprite.position = at_position
		self.add_child(data.duplicate())
		data.queue_free()
	else:
		if node1 != null and node2 != null and has_node("Sprite"):
			var child1 = node1.get_child(0)  
			var child2 = node2.get_child(0)  
			if child1 != null and child2 != null:  
				swap_child_nodes(node1, child1, node2, child2)
	pass

func swap_child_nodes(parent1: Node, child1: Node, parent2: Node, child2: Node):
	if parent1 != null and child1 != null and parent2 != null and child2 != null: 
		# 从各自的父节点中移除子节点
		parent1.remove_child(child1)
		parent2.remove_child(child2)

		# 交换子节点的位置
		var pos1 = child1.get_index()
		var pos2 = child2.get_index()
		child1.set_index(pos2)
		child2.set_index(pos1)

		# 将子节点重新添加到各自的父节点中
		parent1.add_child(child2)
		parent2.add_child(child1)
