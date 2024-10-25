extends Control
## This script manages the board state. It handles move events and ensures that the two boards remain the
## same accross the two devices. It manages the selection and deselction of tiles.


# preload the tile resource for later use.
var tile = preload("res://tile.tscn")

# create a GameState object.
var board = GameState.new()

# The @onready notation means to only load the variable after the scene has loaded.
# This allows the variable to reference a resource that only exists after the scene
# loads. These variables are references to various nodes in the scene for later use.
@onready var grid = $panel_container/h_box_container/aspect_ratio_container/pieces
@onready var whoturn = $panel_container/h_box_container/panel_container/v_box_container/whoturn
@onready var save_game_button = $panel_container/h_box_container/panel_container/v_box_container/save_game
@onready var file_path_lineedit = $panel_container/h_box_container/panel_container/v_box_container/file_path
@onready var load_game_button = $panel_container/h_box_container/panel_container/v_box_container/load_game


# this function is called when the scene has loaded.
func _ready():
	"""
	Setup the default board and connect the server_disconnected signal.
	"""
	blit(board.to_rpc())
	Core.server_disconnected.connect(_server_dis)


func _server_dis():
	"""
	Called whenever the server disconnects and we are a client.
	Return to the start scene but first take note of the reason
	for returning so that start.tscn can give an appropriate warning/error.
	"""
	Core.returning_because_server_quit = true
	get_tree().change_scene_to_file("res://start.tscn")

# this variable tracks the tile that the user has selected.
# tiles are selected by clicking on them.
var selected_tile = null


func _process(_delta):
	"""
	Called every frame. Handles the "escape" action and updates the turn indicator.
	"""
	if Input.is_action_just_pressed("escape"):
		if selected_tile is Vector2i:
			# if there is a valid selected tile then deselect it.
			grid.get_children()[tile_pos_to_index(selected_tile)].deselect()
			selected_tile = null

	# update the turn indicator.
	whoturn.text = (
		# if it's whites turn and we are white or alternativly if it's not whites turn and we are not playing white
		# then it must be our turn.
		"It's your turn." if board.wtm == Core.playing_as_white else "It's your opponents turn."
	)


func tile_clicked(tile_position: Vector2i):
	"""
	Called whenever a tile is clicked. Takes the position of the clicked tile as an argument
	and handles this event appropiratly, selecting the tile, moving a piece or doing nothing
	depending on the state of the game.
	"""
	# if we have a selected tile
	if selected_tile:
		# check if the selected tile is of the same colour as the destination and if so don't move.
		# this stops the user from capturing their own pieces.
		if Core.are_same_colour(
			get_tile_by_position(selected_tile).piece, get_tile_by_position(tile_position).piece
		):
			# select the new tile and deselect the old one. Also update the selected tile variable.
			get_tile_by_position(tile_position).select()
			get_tile_by_position(selected_tile).deselect()
			selected_tile = tile_position
			
			# leave the function to avoid calling the below code. The click event has
			# been handled successfully and so no further action is needed from this function.
			return
		
		# by this point we know that the new tile is not the same colour as the old tile.
		# this means we can move the old tile to the new tile. This "makes a move" on the board
		# potentially capturing an enemy piece.
		
		# using rpc means the move will happen on both our board and the remote board.
		move_piece.rpc(selected_tile, tile_position)
		
		# after a move no tile should be selected so delselect the current tile.
		get_tile_by_position(selected_tile).deselect()
		selected_tile = null
	
	# otherwise there is no currently selected tile so we will be selecting one.
	elif get_tile_by_position(tile_position).has_piece():
		if (
			(
				Core.are_same_colour(
					get_tile_by_position(tile_position).piece, Core.PIECES.BLACK_KING
				)
				and Core.playing_as_white
			)
			or (
				Core.are_same_colour(
					get_tile_by_position(tile_position).piece, Core.PIECES.WHITE_KING
				)
				and not Core.playing_as_white
			)
		):
			return  # if you are playing as white and try and select a black piece or vice versa then return

		# if they are not the same i.e. it's whites turn and we are playing black or it's blacks turn and we are playing white.
		if not (board.wtm == Core.playing_as_white):
			return  # can't move if it's not your turn.
		
		# select the new tile and update the tracker variable.
		get_tile_by_position(tile_position).select()
		selected_tile = tile_position


# NOTE: position's are global, i.e. they are the same across the two boards.
# Vector2i(0,0) will always be black's queen-side rook (because that is the top
# left square from white's point of view).
#
# index's are local, i.e. they represent the local point of view of the board
# and will be different across instances. The index 0 will always be the top
# left square on both boards and will only be equivalent to Vector2i(0,0) on
# an un-flipped board (with white at the bottom).


func tile_pos_to_index(pos: Vector2i, flipped: bool = not Core.playing_as_white):
	"""
	Convert a tile position in Vector2i form into an index in int form. If flipped is
	true then take into accoun that the board will be upside down as we are playing black.
	"""
	if flipped:
		# the use of 7 - pos.y instead of pos.y flips the y (up/down) direction.
		# 7 is used instead of the expected 8 because of 0 based indexing.
		return (7 - pos.y) * 8 + pos.x
	else:
		# if the board is not flipped then return 8 steps for every y pos and 1 for every x pos.
		return pos.y * 8 + pos.x


func tile_index_to_pos(index: int, flipped: bool = not Core.playing_as_white):
	"""
	Convert a tile index in int form into a position in Vector2i form. If flipped is
	true then take into account that the board will be upside down as we are playing black.
	"""
	# use % (modulo) and / (floor division) to find the pos.
	@warning_ignore("integer_division")
	var x = Vector2i(index % 8, index / 8)
	if flipped:
		x.y = 7 - x.y
	return x


func get_tile_by_position(pos: Vector2i, flipped: bool = not Core.playing_as_white):
	"""
	Return the tile object at the given position.
	"""
	return grid.get_children()[tile_pos_to_index(pos, flipped)]

# the rpc annotation allows this function to be called from the remote computer
# the "call_local" means to call this function locally as well as remotly whenever
# RPC-ing it. The "any_peer" means the client is allowed to call it on the host.
@rpc("call_local", "any_peer")
func move_piece(from: Vector2i, to: Vector2i):
	"""
	Moves the piece at "from" to the "to" position then render the board again.
	"""
	# perform the move then render the board.
	board.perform_move(from, to)
	blit(board.to_rpc())


# this should only be rpc'd when the entire board state is changed at once rather than
# moving a single piece. For moving single pieces move_piece has less network usage.
@rpc("call_local", "any_peer")
func blit(
	_board: Dictionary, update_state: bool = false, playing_white: bool = Core.playing_as_white
):
	"""
	Write the state of `_board` to the screen. If `playing_white` is false render upside down.
	If `update_state` is true then update the board variable to match the `_board` argument.
	"""
	var flipped = not playing_white
	if not update_state:
		# create a local variable to overshadow the global `board` variable.
		@warning_ignore("shadowed_variable", "unused_variable")
		var board = GameState.new()

	# initialise the board from the RPC-able data.
	board.from_rpc(_board)

	# flip the board if required.
	var bd
	if flipped:
		bd = board.flipped()
	else:
		bd = board.not_flipped()

	# remove all current children before blitting.
	# this is done by first removing it from the grid
	# then specifically deleting it through the variable
	# reference. 
	for i in grid.get_children():
		grid.remove_child(i)
		i.queue_free()

	var i = 0
	for a in bd:
		for b in a:
			# create a new tile and set its piece and background values.
			var new = tile.instantiate()
			new.set_piece(b)
			@warning_ignore("integer_division")
			new.set_bg((i - i / 8) % 2 == 0)

			# rebind the click events.
			new.clicked.connect(tile_clicked.bind(tile_index_to_pos(i, flipped)))
			i += 1
			grid.add_child(new)


func get_desktop_path():
	"""
	Returns the path to the Desktop if on Windows. Otherwise default to the user:// directory.
	"""
	# get the desktop path.
	var desktop_path = ""
	var os_name = OS.get_name()
	if os_name == "Windows":
		# On Windows the Desktop is inside the user directory. Simply add "/Desktop" to the user folder.
		desktop_path = OS.get_environment("USERPROFILE") + "/Desktop"
	else:
		printerr(
			"OS not supported. This app is currently only available for Windows."
		)
		print("Saving data to user data directory instead.")
		
		# if the desktop path can't be found then default to godot's
		# user data directory.
		desktop_path = "user://"

	return desktop_path


func _on_save_game_button_down():
	"""
	Called whenever the "save game" button is clicked. Saves the game as a file.
	"""
	var err = ResourceSaver.save(board, get_desktop_path() + "/saved_game.tres")
	if err != OK:
		printerr("Failed to save resource")
		save_game_button.text = "Failed to save resource. Click to try again."


func _on_load_game_button_down():
	"""
	Called whwnever the "load game" button is clicked. Loades the game from the file path provided by
	the "file_path" lineedit.
	"""
	# This is an example of the complex programming technique: "reads from, or writes to, files or other persistent storage"
	var loaded_game = ResourceLoader.load(
		file_path_lineedit.text
	)
	if loaded_game:
		board = loaded_game
		blit.rpc(board.to_rpc(), true)
	else:
		printerr("Failed to load data.")
		load_game_button.text = "Failed to load resource. Click to try again."


func _on_pass_button_down():
	"""
	Called whenever the "pass" button is clicked. Makes a dummy move to
	cause a change of turn without actually moving a piece.
	"""
	# move the 0,0 piece back to the same spot faking a move.
	if not (board.wtm == Core.playing_as_white):
		return  # can't pass if it's not your turn.
	
	# Locate an empty square and move it to itself.
	for a in 8:
		for b in 8:
			# If we have found an empty piece then move it to itself.
			# This is technically making a move so it is now the other
			# players turn effectivly passing.
			if board.board[b][a] == Core.PIECES.EMPTY_SQUARE:
				move_piece.rpc(Vector2i(a, b), Vector2i(a, b))
				return
