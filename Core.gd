extends Node

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
	"receptive"]
var ip_address:String
func _ready():
	DisplayServer.window_set_min_size(Vector2i(1152,648))
	if OS.has_feature("windows") and OS.has_environment("COMPUTERNAME"): # Windows
		ip_address = IP.resolve_hostname(str(OS.get_environment("COMPUTERNAME")),IP.TYPE_IPV4)
	elif OS.has_feature("x11") and OS.has_environment("HOSTNAME"): # Linux
		ip_address = IP.resolve_hostname(str(OS.get_environment("HOSTNAME")),IP.TYPE_IPV4)
	elif OS.has_feature("OSX") and OS.has_environment("HOSTNAME"): # MacOS
		ip_address = IP.resolve_hostname(str(OS.get_environment("HOSTNAME")),IP.TYPE_IPV4)

func ip_to_code(ip:String):
	var x = ""
	for i in ip.split(IP_DELIMITER):
		x += words[int(i)] + CODE_DELIMITER
	return x.left(-1)

func code_to_ip(code:String):
	var x = ""
	for i in code.split(CODE_DELIMITER):
		x += str(words.find(i)) + IP_DELIMITER
	return x.left(-1)

# Multiplayer functionality
const DEFAULT_PORT = 7001 # 7000 is the default in the godot docs so I figure 7001 is safe to use.
func create_server(port:int=DEFAULT_PORT,max_clients:int=100):
	var peer = ENetMultiplayerPeer.new()
	peer.create_server(port,max_clients)
	multiplayer.multiplayer_peer=peer

	multiplayer.peer_connected.connect(_peer_connected)
	multiplayer.peer_disconnected.connect(_peer_disconnected)

func create_client(ip:String,port:int=DEFAULT_PORT):
	var peer = ENetMultiplayerPeer.new()
	peer.create_client(ip, port)
	multiplayer.multiplayer_peer = peer

	multiplayer.peer_connected.connect(_peer_connected)
	multiplayer.peer_disconnected.connect(_peer_disconnected)

	multiplayer.connected_to_server.connect(_connected_to_server)
	multiplayer.connection_failed.connect(_connection_failed)
	multiplayer.server_disconnected.connect(_server_disconnected)

func _peer_connected(id:int):
	print("peer: "+str(multiplayer.get_unique_id())+" receiving conenction from peer: "+str(id))

func _peer_disconnected(id:int):
	pass

func _connected_to_server():
	pass

func _connection_failed():
	pass

func _server_disconnected():
	pass
