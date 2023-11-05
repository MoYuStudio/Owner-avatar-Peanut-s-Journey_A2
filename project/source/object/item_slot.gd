
extends PanelContainer

func _get_drag_data(at_position):
	if has_node("Item"):
		var texture = TextureRect.new()
		texture.texture = $Item/Sprite.texture
		texture.scale = $Item/Sprite.scale
		texture.texture_filter = 1
		set_drag_preview(texture)
		return $Item
	return true
	pass
	
func _can_drop_data(at_position, data):
	return true
	pass

func _drop_data(at_position,data):
	if data and !has_node("Item"):
		var new_sprite = data.duplicate()
		new_sprite.position = at_position
		self.add_child(data.duplicate())
		data.queue_free()
	pass


