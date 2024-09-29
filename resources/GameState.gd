class_name GameState extends Resource

# A note on vectors.
# Godot vectors use a positive y value for down. Whenever Vector2i's are used
# for board positions they will use this convention. Whenever chess coords
# e.g. e4 are used they will follow chess direction conventions.  


enum PIECES {
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

var DEFAULT_BOARD = [
	[PIECES.BLACK_ROOK  , PIECES.BLACK_KNIGHT, PIECES.BLACK_BISHOP, PIECES.BLACK_QUEEN , PIECES.BLACK_KING  , PIECES.BLACK_BISHOP, PIECES.BLACK_KNIGHT, PIECES.BLACK_ROOK  ],
	[PIECES.BLACK_PAWN  , PIECES.BLACK_PAWN  , PIECES.BLACK_PAWN  , PIECES.BLACK_PAWN  , PIECES.BLACK_PAWN  , PIECES.BLACK_PAWN  , PIECES.BLACK_PAWN  , PIECES.BLACK_PAWN  ],
	[PIECES.EMPTY_SQUARE, PIECES.EMPTY_SQUARE, PIECES.EMPTY_SQUARE, PIECES.EMPTY_SQUARE, PIECES.EMPTY_SQUARE, PIECES.EMPTY_SQUARE, PIECES.EMPTY_SQUARE, PIECES.EMPTY_SQUARE],
	[PIECES.EMPTY_SQUARE, PIECES.EMPTY_SQUARE, PIECES.EMPTY_SQUARE, PIECES.EMPTY_SQUARE, PIECES.EMPTY_SQUARE, PIECES.EMPTY_SQUARE, PIECES.EMPTY_SQUARE, PIECES.EMPTY_SQUARE],
	[PIECES.EMPTY_SQUARE, PIECES.EMPTY_SQUARE, PIECES.EMPTY_SQUARE, PIECES.EMPTY_SQUARE, PIECES.EMPTY_SQUARE, PIECES.EMPTY_SQUARE, PIECES.EMPTY_SQUARE, PIECES.EMPTY_SQUARE],
	[PIECES.EMPTY_SQUARE, PIECES.EMPTY_SQUARE, PIECES.EMPTY_SQUARE, PIECES.EMPTY_SQUARE, PIECES.EMPTY_SQUARE, PIECES.EMPTY_SQUARE, PIECES.EMPTY_SQUARE, PIECES.EMPTY_SQUARE],
	[PIECES.WHITE_PAWN  , PIECES.WHITE_PAWN  , PIECES.WHITE_PAWN  , PIECES.WHITE_PAWN  , PIECES.WHITE_PAWN  , PIECES.WHITE_PAWN  , PIECES.WHITE_PAWN  , PIECES.WHITE_PAWN  ],
	[PIECES.WHITE_ROOK  , PIECES.WHITE_KNIGHT, PIECES.WHITE_BISHOP, PIECES.WHITE_QUEEN , PIECES.WHITE_KING  , PIECES.WHITE_BISHOP, PIECES.WHITE_KNIGHT, PIECES.WHITE_ROOK  ],]

var board = DEFAULT_BOARD


func pos2vector(pos:String):
	# these are backwards because of godots backwards y coords.
	return Vector2i("abcdefgh".find(pos[0]),"87654321".find(pos[0]))

func vector2pos(vector:Vector2i):
	return "abcdefgh"[vector.x]+"87654321"[vector.y]

func fliped():
	var x=board
	x.reverse()
	return x

func perform_move(from:Vector2i, to:Vector2i):
	"""
	Moves the piece at square "from" to square "to" regardless of legal moves.
	If the piece is a pawn moving to its final rank then promote it to a queen.
	"""
	if board[from.y][from.x] == PIECES.WHITE_PAWN and to.y == 0:
		# if the piece is a white pawn moving to its final rank replace it with a queen.
		board[to.y][to.x] = PIECES.WHITE_QUEEN
	elif board[from.y][from.x] == PIECES.BLACK_PAWN and to.y == 8:
		# same with a black one.
		board[to.y][to.x] = PIECES.BLACK_QUEEN
	else:
		# otherwise keep the piece as is.
		board[to.y][to.x] = board[from.y][from.x]
	
	# clear the "from" square to avoid duplicating the piece.
	board[from.y][from.x] = PIECES.EMPTY_SQUARE

