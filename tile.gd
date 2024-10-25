extends PanelContainer

signal clicked

# preload the white and black background resources.
var white = preload("res://resources/white_background.tres")
var black = preload("res://resources/black_background.tres")

# tracks the piece for this tile.
var piece: int = 0


func set_bg(is_white: bool = true):
	"""
	Sets the background of this tile to either black or white.
	"""
	if is_white:
		self["theme_override_styles/panel"] = white
	else:
		self["theme_override_styles/panel"] = black


func set_piece(_piece: int = 0):
	"""
	Sets the piece for this tile. Defaults to empty so calling this
	without arguments will clear the tile of it's piece.
	"""
	$margin_container/texture_rect.texture = Core.piece_textures[_piece]
	piece = _piece


func has_piece():
	"""
	Return true if this tile has a piece on it.
	"""
	return piece > 0


func _on_gui_input(event):
	"""
	Called whenever there is a GUI input action on this tile.
	"""
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		# emit the clicked signal if the event is a left mouse click.
		clicked.emit()


func select():
	"""
	Tint the tile slightly to show the user that this tile is selected.
	"""
	modulate = Color(1, 0, 0.431, 0.5)


func deselect():
	"""
	Set the tint on the tile back to normal visually "deselecting" the tile.
	"""
	modulate = Color(1, 1, 1)
