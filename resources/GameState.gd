class_name GameState extends Resource

var board = [
	[PIECES.BLACK_ROOK,PIECES.BLACK_KNIGHT,PIECES.BLACK_BISHOP,PIECES.BLACK_QUEEN,PIECES.BLACK_KING,PIECES.BLACK_BISHOP,PIECES.BLACK_KNIGHT,PIECES.BLACK_ROOK],
	[PIECES.BLACK_PAWN,PIECES.BLACK_PAWN  ,PIECES.BLACK_PAWN  ,PIECES.BLACK_PAWN ,PIECES.BLACK_PAWN,PIECES.BLACK_PAWN  ,PIECES.BLACK_PAWN  ,PIECES.BLACK_PAWN],
	[null             ,null               ,null               ,null              ,null             ,null               ,null               ,null             ],
	[null             ,null               ,null               ,null              ,null             ,null               ,null               ,null             ],
	[null             ,null               ,null               ,null              ,null             ,null               ,null               ,null             ],
	[null             ,null               ,null               ,null              ,null             ,null               ,null               ,null             ],
	[PIECES.WHITE_PAWN,PIECES.WHITE_PAWN  ,PIECES.WHITE_PAWN  ,PIECES.WHITE_PAWN ,PIECES.WHITE_PAWN,PIECES.WHITE_PAWN  ,PIECES.WHITE_PAWN  ,PIECES.WHITE_PAWN],
	[PIECES.WHITE_ROOK,PIECES.WHITE_KNIGHT,PIECES.WHITE_BISHOP,PIECES.WHITE_QUEEN,PIECES.WHITE_KING,PIECES.WHITE_BISHOP,PIECES.WHITE_KNIGHT,PIECES.WHITE_ROOK],
]

enum PIECES  {
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
	BLACK_PAWN,
}

func pos2vector(pos:String):
	return Vector2i("abcdefgh".find(pos[0]),"12345678".find(pos[0]))

func vector2pos(vector:Vector2i):
	return "abcdefgh"[vector.x]+"12345678"[vector.y]

func print_test():
	print(pos2vector("a1"))
	print(pos2vector("a2"))
	print(pos2vector("a1"))
	print(pos2vector("a1"))
	print(pos2vector("a1"))
