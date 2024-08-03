extends PanelContainer

signal clicked

var white = preload("res://white_background.tres")
var black = preload("res://black_background.tres")
var piece:String=""

func set_bg(is_white:bool=true):
	if is_white:
		self["theme_override_styles/panel"] = white
	else:
		self["theme_override_styles/panel"] = black

func set_piece(_piece:String):
	$margin_container/texture_rect.texture=Core.pieces[_piece]
	piece = _piece

func has_piece():
	return piece!=""

func _on_gui_input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		clicked.emit()

func select():
	modulate = Color(1, 0, 0.431,0.5)

func deselect():
	modulate = Color(1, 1, 1)

func set_move_hint(on:bool=true):
	if on:
		pass
	else:
		pass
