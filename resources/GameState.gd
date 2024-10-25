class_name GameState extends Resource

# This script/resource is an example of the complex programming technique: "defines class(es) and creates objects."
# Custom resources are godot's equivalent of defining classes. The "creating objects" part is on line 5 of board.gd
# among other places. This also satisfies the complex programming technique: "defines and uses custom types(s)"
# which is really pretty much the same thing because defining a class is a custom type.


# A note on vectors.
# Godot vectors use a positive y value for down. Whenever Vector2i's are used
# for board positions they will use this convention as opposed to the standard
# chess positioning conventions (a1 in the bottom left to h8 in the top right).

# NOTE: The gamestate stored in this resource represents a global board state
# and, while it provides functions to access a flipped version of its board,
# will store the board in its un-flipped state. The board state of any two
# GameState resources in different instances of the same game should be identical.

# DEFAULT_BOARD uses this a lot so a shorter name is benificial.
var PIECES = Core.PIECES

var DEFAULT_BOARD = [
	[PIECES.BLACK_ROOK  , PIECES.BLACK_KNIGHT, PIECES.BLACK_BISHOP, PIECES.BLACK_QUEEN , PIECES.BLACK_KING  , PIECES.BLACK_BISHOP, PIECES.BLACK_KNIGHT, PIECES.BLACK_ROOK  ],
	[PIECES.BLACK_PAWN  , PIECES.BLACK_PAWN  , PIECES.BLACK_PAWN  , PIECES.BLACK_PAWN  , PIECES.BLACK_PAWN  , PIECES.BLACK_PAWN  , PIECES.BLACK_PAWN  , PIECES.BLACK_PAWN  ],
	[PIECES.EMPTY_SQUARE, PIECES.EMPTY_SQUARE, PIECES.EMPTY_SQUARE, PIECES.EMPTY_SQUARE, PIECES.EMPTY_SQUARE, PIECES.EMPTY_SQUARE, PIECES.EMPTY_SQUARE, PIECES.EMPTY_SQUARE],
	[PIECES.EMPTY_SQUARE, PIECES.EMPTY_SQUARE, PIECES.EMPTY_SQUARE, PIECES.EMPTY_SQUARE, PIECES.EMPTY_SQUARE, PIECES.EMPTY_SQUARE, PIECES.EMPTY_SQUARE, PIECES.EMPTY_SQUARE],
	[PIECES.EMPTY_SQUARE, PIECES.EMPTY_SQUARE, PIECES.EMPTY_SQUARE, PIECES.EMPTY_SQUARE, PIECES.EMPTY_SQUARE, PIECES.EMPTY_SQUARE, PIECES.EMPTY_SQUARE, PIECES.EMPTY_SQUARE],
	[PIECES.EMPTY_SQUARE, PIECES.EMPTY_SQUARE, PIECES.EMPTY_SQUARE, PIECES.EMPTY_SQUARE, PIECES.EMPTY_SQUARE, PIECES.EMPTY_SQUARE, PIECES.EMPTY_SQUARE, PIECES.EMPTY_SQUARE],
	[PIECES.WHITE_PAWN  , PIECES.WHITE_PAWN  , PIECES.WHITE_PAWN  , PIECES.WHITE_PAWN  , PIECES.WHITE_PAWN  , PIECES.WHITE_PAWN  , PIECES.WHITE_PAWN  , PIECES.WHITE_PAWN  ],
	[PIECES.WHITE_ROOK  , PIECES.WHITE_KNIGHT, PIECES.WHITE_BISHOP, PIECES.WHITE_QUEEN , PIECES.WHITE_KING  , PIECES.WHITE_BISHOP, PIECES.WHITE_KNIGHT, PIECES.WHITE_ROOK  ],]

@export var board = DEFAULT_BOARD
@export var wtm = true

func flipped():
	"""
	Return a copy of the board from black's perspective.
	"""
	var x=board.duplicate()
	x.reverse()
	return x

func not_flipped():
	"""
	Return a copy of the board from white's perspective.
	"""
	var x=board.duplicate()
	return x

func perform_move(from:Vector2i, to:Vector2i):
	"""
	Moves the piece at square "from" to square "to" regardless of legal moves.
	If the piece is a pawn moving to its final rank then promote it to a queen.
	"""
	if board[from.y][from.x] == PIECES.WHITE_PAWN and to.y == 0:
		# if the piece is a white pawn moving to its final rank replace it with a queen.
		board[to.y][to.x] = PIECES.WHITE_QUEEN
	elif board[from.y][from.x] == PIECES.BLACK_PAWN and to.y == 7:
		# same with a black one.
		board[to.y][to.x] = PIECES.BLACK_QUEEN
	else:
		# otherwise keep the piece as is.
		board[to.y][to.x] = board[from.y][from.x]

	# clear the "from" square to avoid duplicating the piece.
	board[from.y][from.x] = PIECES.EMPTY_SQUARE
	wtm = not wtm

func to_rpc():
	"""
	Returns a dictionary of data reperesenting this object in an RPC-able format.
	"""
	return {
		"board":board,
		"wtm":wtm
	}

func from_rpc(data:Dictionary):
	"""
	Initialise this obejct from an RPC-able dictionary of data.
	"""
	board = data["board"]
	wtm = data["wtm"]
