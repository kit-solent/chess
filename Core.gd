extends Node

#                 v deliberate extra space to prevent the phrase from showing up in search.
# Various complex   programming techniques are documented in the codebase with comments.
# To find these search (ctrl + shift + f) for: "complex programming technique"
# The first of these can be found below:
# The whole app is an example of the complex programming technique: "creates a graphical user interface (GUI)"

# For the last complex programming technique: "uses complex data structures (e.g.stacks, queues, trees)"
# my program consistently works with Godot's node tree structure, accessing and creating child nodes and
# using signals to communicate with parents. When I use: "get_tree().call_deferred("quit")" (on line 325 of this script)
# I am using a queue. The method call "quit" is added to a queue and is executed when space is available.

signal peer_connected(id)
signal peer_disconnected(id)
signal connected_to_server
signal connection_failed
signal server_disconnected
signal username_received(username, id)
signal backspace

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
	BLACK_PAWN
}

const DEFAULT_PORT = 7001  # 7000 is the default in the godot docs so I figure 7001 is safe to use.
const IP_DELIMITER = "."
const CODE_DELIMITER = " "

# A list of 256 words to make ip codes.
var words = [
	"bath",
	"sniff",
	"bedroom",
	"bathe",
	"month",
	"hour",
	"grease",
	"announce",
	"snail",
	"root",
	"name",
	"disastrous",
	"tickle",
	"protest",
	"carriage",
	"fact",
	"wren",
	"kneel",
	"obedient",
	"grotesque",
	"labored",
	"quilt",
	"stingy",
	"cabbage",
	"cumbersome",
	"living",
	"smooth",
	"nod",
	"look",
	"woman",
	"development",
	"hill",
	"scientific",
	"zephyr",
	"juggle",
	"slope",
	"cup",
	"befitting",
	"minor",
	"pear",
	"grandiose",
	"ill",
	"doubtful",
	"brave",
	"grab",
	"zealous",
	"wrench",
	"skillful",
	"ski",
	"coherent",
	"channel",
	"unusual",
	"invite",
	"harmonious",
	"afternoon",
	"soft",
	"wish",
	"liquid",
	"attack",
	"dad",
	"hope",
	"puzzling",
	"testy",
	"juice",
	"steer",
	"skate",
	"recognize",
	"preserve",
	"guttural",
	"adjoining",
	"flat",
	"chemical",
	"wide-eyed",
	"happen",
	"makeshift",
	"found",
	"tasty",
	"uninterested",
	"dashing",
	"breathe",
	"waiting",
	"divergent",
	"interfere",
	"bizarre",
	"eatable",
	"cow",
	"receive",
	"calculating",
	"identify",
	"ignore",
	"known",
	"knock",
	"fear",
	"support",
	"remarkable",
	"crush",
	"amusing",
	"salty",
	"wakeful",
	"fast",
	"fertile",
	"fantastic",
	"argue",
	"different",
	"nebulous",
	"painful",
	"fence",
	"grubby",
	"meaty",
	"basket",
	"cobweb",
	"tug",
	"knowing",
	"ancient",
	"guard",
	"stain",
	"fail",
	"drink",
	"light",
	"steel",
	"pinch",
	"abrasive",
	"perform",
	"grieving",
	"needy",
	"improve",
	"materialistic",
	"seal",
	"march",
	"succinct",
	"x-ray",
	"selfish",
	"disagreeable",
	"tree",
	"horrible",
	"icicle",
	"successful",
	"boring",
	"industrious",
	"challenge",
	"airplane",
	"voracious",
	"gray",
	"abandoned",
	"thoughtless",
	"gigantic",
	"friend",
	"acoustics",
	"violent",
	"current",
	"laugh",
	"disarm",
	"shivering",
	"angle",
	"invincible",
	"noiseless",
	"rest",
	"bored",
	"brief",
	"humor",
	"adventurous",
	"cats",
	"follow",
	"locket",
	"shaky",
	"crack",
	"offend",
	"cooing",
	"silky",
	"weak",
	"unsightly",
	"attempt",
	"female",
	"school",
	"economic",
	"truck",
	"caring",
	"ultra",
	"poke",
	"servant",
	"deranged",
	"puffy",
	"unfasten",
	"silent",
	"protect",
	"adamant",
	"crowded",
	"horses",
	"handsome",
	"lamentable",
	"cherries",
	"toys",
	"scribble",
	"bless",
	"skip",
	"impossible",
	"arrest",
	"blush",
	"tan",
	"bury",
	"spot",
	"superficial",
	"race",
	"twig",
	"wrathful",
	"awful",
	"bright",
	"hot",
	"remain",
	"dangerous",
	"credit",
	"license",
	"fish",
	"childlike",
	"crook",
	"dynamic",
	"high-pitched",
	"tax",
	"hole",
	"piquant",
	"learn",
	"toy",
	"drum",
	"air",
	"tremendous",
	"inexpensive",
	"clammy",
	"wary",
	"book",
	"fluffy",
	"breath",
	"mark",
	"vengeful",
	"playground",
	"ripe",
	"aromatic",
	"turn",
	"sleepy",
	"sad",
	"wilderness",
	"familiar",
	"resonant",
	"point",
	"measly",
	"children",
	"letters",
	"provide",
	"harm",
	"ludicrous",
	"high",
	"exuberant",
	"flock",
	"tense",
	"change",
	"substantial",
	"receptive",
]
var ip_address: String

var playing_as_white: bool

# tracks the reason for why we are on the start screen.
# if true we are here because the server disconnected.
var returning_because_server_quit = false

var username: String
var connected_peers = {
# in the format: id: "username",
}

# An array of Texture2D's for the game pieces.
var piece_textures = []

var piece_names = [
	"empty square",
	"white king",
	"white queen",
	"white rook",
	"white bishop",
	"white knight",
	"white pawn",
	"black king",
	"black queen",
	"black rook",
	"black bishop",
	"black knight",
	"black pawn",
]


func are_same_colour(piece1: int, piece2: int):
	return (
		(
			piece1 in range(PIECES.WHITE_KING, PIECES.WHITE_PAWN + 1)
			and piece2 in range(PIECES.WHITE_KING, PIECES.WHITE_PAWN + 1)
		)
		or (
			piece1 in range(PIECES.BLACK_KING, PIECES.BLACK_PAWN + 1)
			and piece2 in range(PIECES.BLACK_KING, PIECES.BLACK_PAWN + 1)
		)
	)


func _ready():
	# DisplayServer.window_set_min_size(Vector2i(1152, 648))
	# This works for Windows but not for MacOS and I haven't tested it on Linux.
	if OS.get_name() == "Windows" and OS.has_environment("COMPUTERNAME"):  # Windows
		ip_address = IP.resolve_hostname(str(OS.get_environment("COMPUTERNAME")), IP.TYPE_IPV4)
	else:
		push_error("OS not supported. Only Windows is supported.")
		get_tree().call_deferred("quit")

	piece_textures.append(load("res://art/empty_square.png"))
	for a in ["white", "black"]:
		for b in ["king", "queen", "rook", "knight", "bishop", "pawn"]:
			piece_textures.append(load("res://art/" + a + "_" + b + ".png"))

	# multiplayer signals (all peers)
	multiplayer.peer_connected.connect(_peer_connected)
	multiplayer.peer_disconnected.connect(_peer_disconnected)
	# clients only
	multiplayer.connected_to_server.connect(_connected_to_server)
	multiplayer.connection_failed.connect(_connection_failed)
	multiplayer.server_disconnected.connect(_server_disconnected)


func _process(_delta):
	if Input.is_action_just_pressed("ui_text_backspace"):
		backspace.emit()


func ip_to_code(ip: String):
	"""
	Converts the given ip into a join code and returns it.
	"""
	var x = ""
	for i in ip.split(IP_DELIMITER):
		x += words[int(i)] + CODE_DELIMITER
	return x.left(-1)


func code_to_ip(code: String):
	"""
	Converts the given join code into an ip and returns it.
	"""
	var x = ""
	for i in code.split(CODE_DELIMITER):
		x += str(words.find(i)) + IP_DELIMITER
	return x.left(-1)


# Multiplayer functionality
func create_server(port: int = DEFAULT_PORT, max_clients: int = 100):
	var peer = ENetMultiplayerPeer.new()
	var err = peer.create_server(port, max_clients)
	if err:
		print("Failed to create server. Whacky, huh?")
	else:
		multiplayer.multiplayer_peer = peer


func create_client(ip: String, port: int = DEFAULT_PORT):
	var peer = ENetMultiplayerPeer.new()
	# This will generate an error upon failure.
	var err = peer.create_client(ip, port)
	if err:
		_connection_failed()
	else:
		multiplayer.multiplayer_peer = peer


func _peer_connected(id: int):
	connected_peers[id] = 53  # 53 is not a valid username
	peer_connected.emit(id)
	transmit_data.rpc_id(id, username)


func _peer_disconnected(id: int):
	peer_disconnected.emit(id)


func _connected_to_server():
	connected_to_server.emit()


func _connection_failed():
	connection_failed.emit()


func _server_disconnected():
	server_disconnected.emit()


@rpc("any_peer", "reliable")
func transmit_data(_username):
	"""
	This method is used to transmit the username of the new peer to the host and vice versa.
	"""
	connected_peers[multiplayer.get_remote_sender_id()] = _username
	username_received.emit(_username, multiplayer.get_remote_sender_id())
