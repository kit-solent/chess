extends PanelContainer

signal clicked

var white = preload("res://white_background.tres")
var black = preload("res://black_background.tres")

func set_bg(is_white:bool=true):
	if is_white:
		self["theme_override_styles/panel"] = white
	else:
		self["theme_override_styles/panel"] = black

func set_piece(piece:String):
	$margin_container/texture_rect.texture=Core.pieces[piece]

func _input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		clicked.emit()
