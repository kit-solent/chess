extends Control

var tile = preload("res://tile.tscn")
@onready var grid = $panel_container/h_box_container/aspect_ratio_container/grid_container
var board = GameState.new()

func _ready():
	blit(board, not Core.playing_as_white)

var selected_tile = null
func _process(_delta):
	if Input.is_action_just_pressed("escape"):
		if selected_tile is Vector2i:
			(
				grid
				. get_children()[tile_pos_to_index(selected_tile)]
				. deselect()
			)
			selected_tile = null
	if Input.is_action_just_pressed("debug_key"):
		print("--DEBUG KEY PRESSED ON: "+str(multiplayer.get_unique_id())+"--")

func tile_clicked(tile_position:Vector2i):
	print("clicking tile: "+str(tile_position)+" with index: "+str(tile_pos_to_index(tile_position)))
	if selected_tile:
		# check if the selected tile is of the same colour as the destination and if so don't move.
		if Core.are_same_colour(get_tile_by_position(selected_tile).piece,get_tile_by_position(tile_position).piece):
			get_tile_by_position(tile_position).select()
			get_tile_by_position(selected_tile).deselect()
			selected_tile = tile_position
			return
		move_piece.rpc(selected_tile, tile_position)
		get_tile_by_position(selected_tile).deselect()
		selected_tile = null
		print("piece moved")
	elif get_tile_by_position(tile_position).has_piece():
		if (Core.are_same_colour(get_tile_by_position(tile_position).piece,Core.PIECES.BLACK_KING) and Core.playing_as_white) or\
		   (Core.are_same_colour(get_tile_by_position(tile_position).piece,Core.PIECES.WHITE_KING) and not Core.playing_as_white):
			return # if you are playing as white and try and select a black piece or vice versa then return
		get_tile_by_position(tile_position).select()
		selected_tile = tile_position
		print("selecting new piece")

# NOTE: position's are global, i.e. they are the same accross the two boards.
# Vector2i(0,0) will always be black's queenside rook (because that is the top
# left square from white's point of view).
# 
# index's are local, i.e. they reperesent the local point of view of the board
# and will be different accross instances. The index 0 will always be the top
# left square on both boards and will only be equivalent to Vector2i(0,0) on
# an unflipped board (with white at the bottom).

func tile_pos_to_index(pos:Vector2i, flipped:bool = not Core.playing_as_white):
	if flipped:
		return (7-pos.y)*8 + pos.x
	else:
		return pos.y*8 + pos.x

func tile_index_to_pos(index:int, flipped:bool = not Core.playing_as_white):
	var x = Vector2i(index%8, index/8)
	if flipped:
		x.y = 7-x.y
	return x

func get_tile_by_position(pos:Vector2i, flipped:bool = not Core.playing_as_white):
	return grid.get_children()[tile_pos_to_index(pos, flipped)]

@rpc("call_local", "any_peer")
func move_piece(from:Vector2i, to:Vector2i):
	# perform the move then render the board.
	board.perform_move(from, to)
	blit(board, not Core.playing_as_white)

# this should only be rpc'd when the entire board state is changed at once rather than
# moving a single piece. For moving single pieces move_piece has less network usage.
@rpc("call_local","any_peer") 
func blit(_board:GameState, flipped:bool = false):
	"""
	Write the state of `_board` to the screen. If `flipped` is true render upside down.
	"""
	var bd
	if flipped:
		bd = _board.fliped()
	else:
		bd = _board.notflipped()
	
	# remove all current children before blitting.
	for i in grid.get_children():
		grid.remove_child(i)
		i.queue_free()
	
	var i = 0
	for a in bd:
		for b in a:
			# create a new tile and set its piece and background values.
			var new = tile.instantiate()
			new.set_piece(b)
			new.set_bg((i - i / 8) % 2 == 0)
			
			# rebind the click event.
			new.clicked.connect(tile_clicked.bind(tile_index_to_pos(i, flipped)))
			i += 1
			grid.add_child(new)

func get_desktop_path():
	# get the desktop path.
	var desktop_path = ""
	var os_name = OS.get_name()
	if os_name == "Windows":
		desktop_path = OS.get_environment("USERPROFILE") + "/Desktop"
	elif os_name in ["Linux", "BSD", "OSX"]:
		desktop_path = OS.get_environment("HOME") + "/Desktop"
	else:
		printerr("OS not recognised. Please use one of the following operating systems: Windows, Linux, MacOS (please don't use this one)")
		print("Saving data to user data directory instead.")
		desktop_path = "user://"
	
	return desktop_path

func _on_button_button_down() -> void:
	var err = ResourceSaver.save(board, get_desktop_path()+"/saved_game.tres")
	if err != OK:
		printerr("Failed to save resource")
		$panel_container/h_box_container/panel_container/v_box_container/button.text="Failed to save resource. Click to try again."


func _on_button_2_button_down() -> void:
	print("loading game...")
	var loaded_game = ResourceLoader.load($panel_container/h_box_container/panel_container/v_box_container/line_edit.text)
	if loaded_game:
		board = loaded_game
		# TODO: cannot rpc custom resources. Needs steralisation first. :(
		blit.rpc(board, not Core.playing_as_white)
	else:
		printerr("Failed to load data.")
		$panel_container/h_box_container/panel_container/v_box_container/button2.text = "Failed to load resource. Click to try again."
