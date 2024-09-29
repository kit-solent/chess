extends Control

@onready var grid = $panel_container/aspect_ratio_container/grid_container
var board = GameState.new()

func _ready():
	# even after flipping the board the id's will be consistant accross players.
	for i in 64:
		var new = load("res://tile.tscn").instantiate()
		@warning_ignore("integer_division")
		new.set_bg((i - i / 8) % 2 == 0) #                   / is floordiv by default. How un-pythonic.
		new.clicked.connect(tile_clicked.bind(Vector2i(i%8, i/8)))
		grid.add_child(new)

	var index = 0

	for i in ["rook", "knight", "bishop", "queen", "king", "bishop", "knight", "rook"]:
		grid.get_children()[index].set_piece("black " + i)
		index += 1

	for i in 8:
		grid.get_children()[index].set_piece("black pawn")
		index += 1

	for i in 32:
		index += 1

	for i in 8:
		grid.get_children()[index].set_piece("white pawn")
		index += 1

	for i in ["rook", "knight", "bishop", "queen", "king", "bishop", "knight", "rook"]:
		grid.get_children()[index].set_piece("white " + i)
		index += 1

	if not Core.playing_as_white:
		# flip the board so that our colour is at the bottom.
		var x = $panel_container/aspect_ratio_container/grid_container.get_children()
		x.reverse()
		for i in $panel_container/aspect_ratio_container/grid_container.get_children():
			$panel_container/aspect_ratio_container/grid_container.remove_child(i)
		for i in x:
			$panel_container/aspect_ratio_container/grid_container.add_child(i)


func _process(delta):
	if Input.is_action_just_pressed("escape"):
		(
			$panel_container/aspect_ratio_container/grid_container
			. get_children()[tile_pos_to_index(selected_tile)]
			. deselect()
		)
		selected_tile = null


var selected_tile = null


func tile_clicked(tile_position:Vector2i):
	print("tile clicked: " + str(tile_position))
	if selected_tile:
		move_piece.rpc(selected_tile, tile_position)
		(
			$panel_container/aspect_ratio_container/grid_container
			. get_children()[tile_pos_to_index(tile_position)]
			. deselect()
		)
		selected_tile = null
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


func tile_pos_to_index(pos: Vector2i):
	if not Core.playing_as_white:
		return 63 - (pos.y*8 + pos.x)
	else:
		return pos.y*8 + pos.x


@rpc("call_local", "any_peer")
func move_piece(from:Vector2i, to:Vector2i):
	board.perform_move(from, to)
