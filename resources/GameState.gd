class_name GameState extends Resource

# A note on vectors.
# Godot vectors use a positive y value for down. Whenever Vector2i's are used
# for board positions they will use this convention. Whenever chess coords
# e.g. e4 are used they will follow chess direction conventions.  

signal checkmate(winner)
signal draw(reason)

var DEFAULT_BOARD = [
	[PIECES.BLACK_ROOK  ,PIECES.BLACK_KNIGHT,PIECES.BLACK_BISHOP,PIECES.BLACK_QUEEN ,PIECES.BLACK_KING  ,PIECES.BLACK_BISHOP,PIECES.BLACK_KNIGHT,PIECES.BLACK_ROOK  ],
	[PIECES.BLACK_PAWN  ,PIECES.BLACK_PAWN  ,PIECES.BLACK_PAWN  ,PIECES.BLACK_PAWN  ,PIECES.BLACK_PAWN  ,PIECES.BLACK_PAWN  ,PIECES.BLACK_PAWN  ,PIECES.BLACK_PAWN  ],
	[PIECES.EMPTY_SQUARE,PIECES.EMPTY_SQUARE,PIECES.EMPTY_SQUARE,PIECES.EMPTY_SQUARE,PIECES.EMPTY_SQUARE,PIECES.EMPTY_SQUARE,PIECES.EMPTY_SQUARE,PIECES.EMPTY_SQUARE],
	[PIECES.EMPTY_SQUARE,PIECES.EMPTY_SQUARE,PIECES.EMPTY_SQUARE,PIECES.EMPTY_SQUARE,PIECES.EMPTY_SQUARE,PIECES.EMPTY_SQUARE,PIECES.EMPTY_SQUARE,PIECES.EMPTY_SQUARE],
	[PIECES.EMPTY_SQUARE,PIECES.EMPTY_SQUARE,PIECES.EMPTY_SQUARE,PIECES.EMPTY_SQUARE,PIECES.EMPTY_SQUARE,PIECES.EMPTY_SQUARE,PIECES.EMPTY_SQUARE,PIECES.EMPTY_SQUARE],
	[PIECES.EMPTY_SQUARE,PIECES.EMPTY_SQUARE,PIECES.EMPTY_SQUARE,PIECES.EMPTY_SQUARE,PIECES.EMPTY_SQUARE,PIECES.EMPTY_SQUARE,PIECES.EMPTY_SQUARE,PIECES.EMPTY_SQUARE],
	[PIECES.WHITE_PAWN  ,PIECES.WHITE_PAWN  ,PIECES.WHITE_PAWN  ,PIECES.WHITE_PAWN  ,PIECES.WHITE_PAWN  ,PIECES.WHITE_PAWN  ,PIECES.WHITE_PAWN  ,PIECES.WHITE_PAWN  ],
	[PIECES.WHITE_ROOK  ,PIECES.WHITE_KNIGHT,PIECES.WHITE_BISHOP,PIECES.WHITE_QUEEN ,PIECES.WHITE_KING  ,PIECES.WHITE_BISHOP,PIECES.WHITE_KNIGHT,PIECES.WHITE_ROOK  ],]
var board = DEFAULT_BOARD
enum PIECES  {
	EMPTY_SQUARE,
	WHITE_KING,
	WHITE_QUEEN,
	WHITE_ROOK,
	WHITE_KNIGHT,
	WHITE_BISHOP,
	WHITE_PAWN,
	BLACK_KING,
	BLACK_QUEEN,
	BLACK_ROOK,
	BLACK_KNIGHT,
	BLACK_BISHOP,
	BLACK_PAWN}
var WHITE_PIECES = [
	PIECES.WHITE_KING,
	PIECES.WHITE_QUEEN,
	PIECES.WHITE_ROOK,
	PIECES.WHITE_KNIGHT,
	PIECES.WHITE_BISHOP,
	PIECES.WHITE_PAWN]
var BLACK_PIECES = [
	PIECES.BLACK_KING,
	PIECES.BLACK_QUEEN,
	PIECES.BLACK_ROOK,
	PIECES.BLACK_KNIGHT,
	PIECES.BLACK_BISHOP,
	PIECES.BLACK_PAWN]


func pos2vector(pos:String):
	# these are backwards because of godots backwards y coords.
	return Vector2i("abcdefgh".find(pos[0]),"87654321".find(pos[0]))

func vector2pos(vector:Vector2i):
	return "abcdefgh"[vector.x]+"87654321"[vector.y]

var entire_board

var single_adjacents
var single_diagonals
var long_adjacents
var long_diagonals

var king_moves
var queen_moves
var rook_moves
var knight_moves
var bishop_moves
var pawn_moves

var moves

func init():
	single_adjacents = [
		Vector2i.UP,Vector2i.DOWN,Vector2i.LEFT,Vector2i.RIGHT
	]
	
	single_diagonals = [
		Vector2i.UP + Vector2i.RIGHT,
		Vector2i.DOWN, Vector2i.RIGHT,
		Vector2i.DOWN + Vector2i.LEFT,
		Vector2i.UP + Vector2i.LEFT
	]
	
	long_diagonals = []
	long_adjacents = []
	
	for i in 8: # 8 squares in every direction is enough to cover the whole board.
		for a in single_diagonals:
			long_diagonals.append(a*(i+1))
		
		for a in single_adjacents:
			long_adjacents.append(a*(i+1))
	
	king_moves   = single_adjacents
	queen_moves  = long_adjacents + long_diagonals
	rook_moves   = long_adjacents
	bishop_moves = long_diagonals
	knight_moves = [
		Vector2i(-2,-1),
		Vector2i(-2, 1),
		Vector2i(-1,-2),
		Vector2i(-1, 2),
		Vector2i( 2,-1),
		Vector2i( 2, 1),
		Vector2i( 1,-2),
		Vector2i( 1, 2)
	]
	
	pawn_moves = [
		Vector2.UP,
		2*Vector2.UP # Pawns can move 2 squares on their first move.
	]
	
	moves = {
		PIECES.WHITE_KING: king_moves,
		PIECES.BLACK_KING: king_moves,
		PIECES.WHITE_QUEEN: queen_moves,
		PIECES.BLACK_QUEEN: queen_moves,
		PIECES.WHITE_ROOK: rook_moves,
		PIECES.BLACK_ROOK: rook_moves,
		PIECES.WHITE_BISHOP: bishop_moves,
		PIECES.BLACK_BISHOP: bishop_moves,
		PIECES.WHITE_KNIGHT: knight_moves,
		PIECES.BLACK_KNIGHT: knight_moves,
		PIECES.WHITE_PAWN: pawn_moves,
		PIECES.BLACK_PAWN: pawn_moves
	}
	
	entire_board = []
	for x in range(1,9):
		for y in range(1,9):
			entire_board.append(Vector2i(x,y))

func perform_move(from:Vector2i, to:Vector2i):
	"""
	Moves the piece at square "from" to square "to" regardless of legal moves.
	"""
	board[to.y][to.x] = board[from.y][from.x]
	board[from.y][from.x] = PIECES.EMPTY_SQUARE

func make_move_if_legal(start:Vector2i, stop:Vector2i):
	pass

func set_intersection(set1:Array, set2:Array) -> Array:
	"""
	Simulates the set intersection operator with arrays.
	"""
	var new=[]
	for i in set1:
		if i in set2:
			new.append(i)
	return new




func is_legal_move(_from:String,_to:String):
	var from = pos2vector(_from)
	var to = pos2vector(_to)
	#                 7-from.y is used because the board is stored from top to bottom and the y values go from bottom to top.
	var piece = board[7-from.y][from.x]
	var potential_moves = moves[piece] # an array of potential moves relative to
	
	# eliminate moves that are off the board.
	potential_moves = set_intersection(potential_moves,entire_board)
	
	# eliminate moves blocked by allied pieces.
	for y in board:
		for x in y:
			if board[y][x]:pass


func all_legal_moves(_position:String, consider_checks = true):
	var pos = pos2vector(_position)
	var piece = board[pos.y][pos.x]
	var pot_moves = []
	for i in moves[piece]:
		pot_moves.append(i + pos) # get an array of all potential moves relative to the pieces current position.
	pot_moves = set_intersection(pot_moves, entire_board)
	
	if piece == PIECES.EMPTY_SQUARE:
		return [] # no legal moves for an empty square
	
	if piece in [PIECES.WHITE_KING, PIECES.BLACK_KING]:
		var _rtrn = []
		for i in pot_moves:
			# Kings can never move to a square with a friendly piece on it.
			if piece == PIECES.WHITE_KING:
				if board[i.y][i.x] in WHITE_PIECES:
					continue
			elif piece == PIECES.BLACK_KING:
				if board[i.y][i.x] in BLACK_PIECES:
					continue
			
			if consider_checks:
				var test_check = duplicate() # make a copy of this board
				test_check.perform_move(pos, i) # force the move
				if test_check.is_check(): # and see if the result is in check
					continue
			
			_rtrn.append(i)





func is_check():
	# first check the white king.
	var white_king_pos = find(PIECES.WHITE_KING)[0] # there should only ever be one.
	for i in get_pieces_by_colour(false):
		# if the position of the king is in the legal moves of any enemy piece.
		if white_king_pos in all_legal_moves(i,false):
			return true
	
	# then check the black king.
	var black_king_pos = find(PIECES.BLACK_KING)[0] # there should only ever be one.
	for i in get_pieces_by_colour(true):
		# if the position of the king is in the legal moves of any enemy piece.
		if black_king_pos in all_legal_moves(i,false):
			return true

func get_pieces_by_colour(white:bool):
	"""
	Returns an array of all black pieces on the board.
	"""
	var pieces = []
	var list_pieces
	if white:
		list_pieces = WHITE_PIECES
	else:
		list_pieces = BLACK_PIECES
	for y in board:
		for x in y:
			if board[y][x] in list_pieces:
				pieces.append(Vector2i(x,y))
	return pieces

func find(piece):
	"""
	Returns the positions of all pieces of the given type on the board.
	"""
	var pieces = []
	for y in board:
		for x in y:
			if board[y][x] == piece:
				pieces.append(Vector2i(x,y))
	return pieces
