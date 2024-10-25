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

# various signals emmitted when certain things happen to allow the rest of the scene tree to respond.
signal peer_connected(id)
signal peer_disconnected(id)
signal connected_to_server
signal connection_failed
signal server_disconnected
signal username_received(username, id)
signal backspace

# an enum of the pieces in a chess game.
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

# These are the characters used to seperate elements of an ip address and join code respectivly.
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

# the ip address of the current local computer
var ip_address: String

# a boolean to track if we are playing as white or not. If false we are playing black.
var playing_as_white: bool

# tracks the reason for why we are on the start screen.
# if true we are here because the server disconnected.
var returning_because_server_quit = false

# our local username
var username: String

# a dictionary to store connected peers.
var connected_peers = {
# in the format: id: "username",
}

# An array of Texture2D's for the game pieces.
var piece_textures = []

# a list of piece names to match the enum: "PIECES".
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
	"""
	Returns true if "piece1" is of the same colour as "piece2".
	Returns false otherwise or if either piece is empty.
	"""
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
	"""
	Called when the scene finishes loading. Trys to find the username and quits
	if an unsupported OS is detected. Also loads the game art and connects the
	multiplayer signals.
	"""
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
	"""
	Called every frame. Used to emit a backspace signal whenever the
	backspace key is pressed
	"""
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


func create_server(port: int = DEFAULT_PORT, max_clients: int = 100):
	"""
	This function creates a server.
	"""
	var peer = ENetMultiplayerPeer.new()
	var err = peer.create_server(port, max_clients)
	if err:
		print("Failed to create server. Whacky, huh?")
	else:
		multiplayer.multiplayer_peer = peer


func create_client(ip: String, port: int = DEFAULT_PORT):
	"""
	This function creates a client.
	"""
	var peer = ENetMultiplayerPeer.new()
	# This will generate an error upon failure.
	var err = peer.create_client(ip, port)
	if err:
		_connection_failed()
	else:
		multiplayer.multiplayer_peer = peer


func _peer_connected(id: int):
	"""
	Called on the host and every client whenever another peer connects.
	"""
	# set a dummy username untill the actual username is transmitted.
	connected_peers[id] = 53  # 53 is not a valid username
	peer_connected.emit(id)
	
	# send our username to the new peer.
	transmit_data.rpc_id(id, username)

# The below 4 methods are used simply to pass on multiplayer peer
# signals to the rest of the scene tree.

func _peer_disconnected(id: int):
	"""
	Called on the server and every peer when another peer disconnects.
	"""
	peer_disconnected.emit(id)


func _connected_to_server():
	"""
	Called on a client when it successfully connects to the server.
	"""
	connected_to_server.emit()


func _connection_failed():
	"""
	Called on a client whenever the connection fails
	for any reason. This could be an invalid join code/
	ip address, or any other network issue.
	"""
	connection_failed.emit()


func _server_disconnected():
	"""
	Called on a client when the server disconnects.
	"""
	server_disconnected.emit()


@rpc("any_peer", "reliable")
func transmit_data(_username):
	"""
	This method is used to transmit the username of the new peer to the host and vice versa.
	"""
	connected_peers[multiplayer.get_remote_sender_id()] = _username
	username_received.emit(_username, multiplayer.get_remote_sender_id())
