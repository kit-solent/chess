extends Node

signal peer_connected(id)
signal peer_disconnected(id)
signal connected_to_server
signal connection_failed
signal server_disconnected

signal username_recieved(username, id)

signal backspace

const DEFAULT_PORT = 7001  # 7000 is the default in the godot docs so I figure 7001 is safe to use.
const IP_DELIMITER = "."
const CODE_DELIMITER = " "

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
	"recognise",
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
	"receptive"
]
var ip_address: String

var playing_as_white: bool

var username: String
var connected_peers = {
# in the format: id: "username",
}

var piece_textures = []

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

func are_same_colour(piece1:int, piece2:int):
	return piece1 in range(PIECES.WHITE_KING, PIECES.WHITE_PAWN+1) and piece2 in range(PIECES.WHITE_KING, PIECES.WHITE_PAWN+1) or\
		   piece1 in range(PIECES.BLACK_KING, PIECES.BLACK_PAWN+1) and piece2 in range(PIECES.BLACK_KING, PIECES.BLACK_PAWN+1)

func get_ip():
	var peer = ENetMultiplayerPeer.new()
	var err = peer.create_server(DEFAULT_PORT, 1)
	if err:
		print("Failed to create server. Whacky, huh?")
	else:
		var local_ip = peer.get_peer(0).get_remote_address()
		peer.close()
		return local_ip

func _ready():
	# DisplayServer.window_set_min_size(Vector2i(1152, 648))
	#if OS.get_name() == "Windows" and OS.has_environment("COMPUTERNAME"):  # Windows
		#ip_address = IP.resolve_hostname(str(OS.get_environment("COMPUTERNAME")), IP.TYPE_IPV4)
	#elif OS.get_name() == "Linux" and OS.has_environment("HOSTNAME"):  # Linux
		#ip_address = IP.resolve_hostname(str(OS.get_environment("HOSTNAME")), IP.TYPE_IPV4)
	#elif OS.get_name() == "macOS" and OS.has_environment("HOSTNAME"):  # MacOS
		#printerr("Mac is not supported because it is a stupid OS that doesn't allow access to ")
		#ip_address = IP.resolve_hostname(str(OS.get_environment("HOSTNAME")), IP.TYPE_IPV4)
	#else:
		#printerr("OS not supported.")
		#get_tree().call_deferred("quit")
	ip_address = get_ip()
	
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
	var x = ""
	for i in ip.split(IP_DELIMITER):
		x += words[int(i)] + CODE_DELIMITER
	return x.left(-1)


func code_to_ip(code: String):
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
	connected_peers[multiplayer.get_remote_sender_id()] = _username
	username_recieved.emit(_username, multiplayer.get_remote_sender_id())
