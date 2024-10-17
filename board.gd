extends Control

var tile = preload("res://tile.tscn")
@onready var grid = $panel_container/h_box_container/aspect_ratio_container/grid_container
var board = GameState.new()


func _ready():
	blit(board.to_rpc())
	Core.server_disconnected.connect(_server_dis)


func _server_dis():
	Core.returning_because_server_quit = true
	get_tree().change_scene_to_file("res://start.tscn")


var selected_tile = null


func _process(_delta):
	if Input.is_action_just_pressed("escape"):
		if selected_tile is Vector2i:
			grid.get_children()[tile_pos_to_index(selected_tile)].deselect()
			selected_tile = null

	$panel_container/h_box_container/panel_container/v_box_container/whoturn.text = (
		"It's your turn." if board.wtm == Core.playing_as_white else "It's your opponents turn."
	)


func tile_clicked(tile_position: Vector2i):
	if selected_tile:
		# check if the selected tile is of the same colour as the destination and if so don't move.
		if Core.are_same_colour(
			get_tile_by_position(selected_tile).piece, get_tile_by_position(tile_position).piece
		):
			get_tile_by_position(tile_position).select()
			get_tile_by_position(selected_tile).deselect()
			selected_tile = tile_position
			return
		move_piece.rpc(selected_tile, tile_position)
		get_tile_by_position(selected_tile).deselect()
		selected_tile = null
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
		get_tile_by_position(tile_position).select()
		selected_tile = tile_position


# NOTE: position's are global, i.e. they are the same accross the two boards.
# Vector2i(0,0) will always be black's queenside rook (because that is the top
# left square from white's point of view).
#
# index's are local, i.e. they reperesent the local point of view of the board
# and will be different accross instances. The index 0 will always be the top
# left square on both boards and will only be equivalent to Vector2i(0,0) on
# an unflipped board (with white at the bottom).


func tile_pos_to_index(pos: Vector2i, flipped: bool = not Core.playing_as_white):
	if flipped:
		return (7 - pos.y) * 8 + pos.x
	else:
		return pos.y * 8 + pos.x


func tile_index_to_pos(index: int, flipped: bool = not Core.playing_as_white):
	@warning_ignore("integer_division")
	var x = Vector2i(index % 8, index / 8)
	if flipped:
		x.y = 7 - x.y
	return x


func get_tile_by_position(pos: Vector2i, flipped: bool = not Core.playing_as_white):
	return grid.get_children()[tile_pos_to_index(pos, flipped)]


@rpc("call_local", "any_peer")
func move_piece(from: Vector2i, to: Vector2i):
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
		var board = GameState.new()

	board.from_rpc(_board)

	var bd
	if flipped:
		bd = board.fliped()
	else:
		bd = board.notflipped()

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
			@warning_ignore("integer_division")
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
		printerr(
			"OS not recognised. Please use one of the following operating systems: Windows, Linux, MacOS (please don't use this one)"
		)
		print("Saving data to user data directory instead.")
		desktop_path = "user://"

	return desktop_path


func _on_button_button_down() -> void:
	var err = ResourceSaver.save(board, get_desktop_path() + "/saved_game.tres")
	if err != OK:
		printerr("Failed to save resource")
		$panel_container/h_box_container/panel_container/v_box_container/button.text = "Failed to save resource. Click to try again."


func _on_button_2_button_down() -> void:
	# This is an example of the complex programming technique: "reads from, or writes to, files or other persistent storage"
	var loaded_game = ResourceLoader.load(
		$panel_container/h_box_container/panel_container/v_box_container/line_edit.text
	)
	if loaded_game:
		board = loaded_game
		blit.rpc(board.to_rpc(), true)
	else:
		printerr("Failed to load data.")
		$panel_container/h_box_container/panel_container/v_box_container/button2.text = "Failed to load resource. Click to try again."


func _on_pass_button_down():
	# move the 0,0 piece back to the same spot faking a move.
	if not (board.wtm == Core.playing_as_white):
		return  # can't pass if it's not your turn.
	for a in 8:
		for b in 8:
			if board.board[b][a] == Core.PIECES.EMPTY_SQUARE:
				move_piece.rpc(Vector2i(a, b), Vector2i(a, b))
				return
