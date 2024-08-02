extends Control

@onready var grid = $panel_container/aspect_ratio_container/grid_container
func _ready():
	for i in 64:
		var new = load("res://tile.tscn").instantiate()
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

func tile_clicked(tile_id):
	pass
