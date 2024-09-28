extends Control

@onready var grid = $panel_container/aspect_ratio_container/grid_container
func _ready():
	# even after flipping the board the id's will be consistant accross players.
	for i in 64:
		var new = load("res://tile.tscn").instantiate()
		@warning_ignore("integer_division")
		new.set_bg((i-i/8)%2==0)
		new.clicked.connect(tile_clicked.bind(i))
		grid.add_child(new)
	
	var index = 0
	
	for i in ["rook","knight","bishop","queen","king","bishop","knight","rook"]:
		grid.get_children()[index].set_piece("black "+i)
		index += 1
	
	for i in 8:
		grid.get_children()[index].set_piece("black pawn")
		index += 1
	
	for i in 32:
		index += 1
	
	for i in 8:
		grid.get_children()[index].set_piece("white pawn")
		index += 1
	
	for i in ["rook","knight","bishop","queen","king","bishop","knight","rook"]:
		grid.get_children()[index].set_piece("white "+i)
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
		$panel_container/aspect_ratio_container/grid_container.get_children()[tile_id_to_index(selected_tile)].deselect()
		selected_tile=null

var selected_tile = null
func tile_clicked(tile_id):
	print("tile clicked: "+str(tile_id))
	if selected_tile:
		move_piece.rpc(selected_tile,tile_id)
		$panel_container/aspect_ratio_container/grid_container.get_children()[tile_id_to_index(tile_id)].deselect()
		selected_tile=null
	elif $panel_container/aspect_ratio_container/grid_container.get_children()[tile_id_to_index(tile_id)].has_piece():
		$panel_container/aspect_ratio_container/grid_container.get_children()[tile_id_to_index(tile_id)].select()
		selected_tile = tile_id

func tile_id_to_index(id:int):
	if not Core.playing_as_white:
		return 63-id
	else:
		return id

@rpc("call_local","any_peer")
func move_piece(from,to):
	var p = $panel_container/aspect_ratio_container/grid_container.get_children()[tile_id_to_index(from)].piece
	$panel_container/aspect_ratio_container/grid_container.get_children()[tile_id_to_index(from)].set_piece("")
	$panel_container/aspect_ratio_container/grid_container.get_children()[tile_id_to_index(to)].set_piece(p)
	
	$panel_container/aspect_ratio_container/grid_container.get_children()[tile_id_to_index(from)].deselect()
	$panel_container/aspect_ratio_container/grid_container.get_children()[tile_id_to_index(to)].deselect()
