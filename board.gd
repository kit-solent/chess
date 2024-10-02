extends Control

var tile = preload("res://tile.tscn")
@onready var grid = $panel_container/aspect_ratio_container/grid_container
var board = GameState.new()

func _ready():
	# even after flipping the board the id's will be consistant accross players.
	for i in 64:
		var new = load("res://tile.tscn").instantiate()
		@warning_ignore("integer_division")
		new.set_bg((i - i / 8) % 2 == 0)
		@warning_ignore("integer_division") #                / is floordiv by default. How un-pythonic.
		new.clicked.connect(tile_clicked.bind(Vector2i(i%8, i/8)))
		grid.add_child(new)

	var index = 0

	for i in [Core.PIECES.BLACK_ROOK, Core.PIECES.BLACK_KNIGHT, Core.PIECES.BLACK_BISHOP, Core.PIECES.BLACK_QUEEN, Core.PIECES.BLACK_KING, Core.PIECES.BLACK_BISHOP, Core.PIECES.BLACK_KNIGHT, Core.PIECES.BLACK_ROOK]:
		grid.get_children()[index].set_piece(i)
		index += 1

	for i in 8:
		grid.get_children()[index].set_piece(Core.PIECES.BLACK_PAWN)
		index += 1

	for i in 32:
		index += 1

	for i in 8:
		grid.get_children()[index].set_piece(Core.PIECES.WHITE_PAWN)
		index += 1

	for i in [Core.PIECES.WHITE_ROOK, Core.PIECES.WHITE_KNIGHT, Core.PIECES.WHITE_BISHOP, Core.PIECES.WHITE_QUEEN, Core.PIECES.WHITE_KING, Core.PIECES.WHITE_BISHOP, Core.PIECES.WHITE_KNIGHT, Core.PIECES.WHITE_ROOK]:
		grid.get_children()[index].set_piece(i)
		index += 1

	if not Core.playing_as_white:
		# flip the board so that our colour is at the bottom.
		var x = $panel_container/aspect_ratio_container/grid_container.get_children()
		x.reverse()
		for i in $panel_container/aspect_ratio_container/grid_container.get_children():
			$panel_container/aspect_ratio_container/grid_container.remove_child(i)
		for i in x:
			$panel_container/aspect_ratio_container/grid_container.add_child(i)


func _process(_delta):
	if Input.is_action_just_pressed("escape"):
		(
			$panel_container/aspect_ratio_container/grid_container
			. get_children()[tile_pos_to_index(selected_tile)]
			. deselect()
		)
		selected_tile = null


var selected_tile = null


func tile_clicked(tile_position:Vector2i):
	if selected_tile:
		move_piece.rpc(selected_tile, tile_position)
		(
			$panel_container/aspect_ratio_container/grid_container
			. get_children()[tile_pos_to_index(tile_position)]
			. deselect()
		)
		selected_tile = null
		print("hereiam")
	elif (
		$panel_container/aspect_ratio_container/grid_container
		. get_children()[tile_pos_to_index(tile_position)]
		. has_piece()
	): # < whats this guy sad about?
		(
			$panel_container/aspect_ratio_container/grid_container
			. get_children()[tile_pos_to_index(tile_position)]
			. select()
		)
		selected_tile = tile_position
		print("orhere")
	print("donesies")


func tile_pos_to_index(pos: Vector2i):
	if not Core.playing_as_white:
		return 63 - (pos.y*8 + pos.x)
	else:
		return pos.y*8 + pos.x


@rpc("call_local", "any_peer")
func move_piece(from:Vector2i, to:Vector2i):
	print(str(multiplayer.get_unique_id())+" is performing a move")
	board.perform_move(from, to)
	blit(board, not Core.playing_as_white)
	print("finished")

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
	for i in $panel_container/aspect_ratio_container/grid_container.get_children():
		$panel_container/aspect_ratio_container/grid_container.remove_child(i)
		i.queue_free()
	print("halfway")
	for a in bd:
		for b in a:
			var new = tile.instantiate()
			new.set_piece(b)
			$panel_container/aspect_ratio_container/grid_container.add_child(new)
