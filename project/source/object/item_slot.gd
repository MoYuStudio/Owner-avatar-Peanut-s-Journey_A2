
extends PanelContainer

func _get_drag_data(at_position):
	if has_node("Sprite"):
		var texture = TextureRect.new()
		texture.texture = $Sprite.texture
		texture.scale = $Sprite.scale
		texture.TEXTURE_FILTER_NEAREST
		set_drag_preview(texture)
		return $Sprite
	return true
	pass

func _can_drop_data(at_position, data):
	return true
	pass

func _drop_data(at_position, data):
	pass
