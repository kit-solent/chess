extends Control

# create a reference to the player_menu using it's shortcut name.
@onready var player_menu = %player_join_game_thingy

# a dictionary of tabs in the form "tab name": tab index. Used to look up tabs by name.
var tabs: Dictionary


func _ready():
	"""
	Called when the scene finishes loading. Initialises the README section
	and sets up the logo effect.
	"""
	# load the contents of README.md into the in-game label.
	var file = FileAccess.open("res://README.md", FileAccess.READ)
	var content = file.get_as_text()
	var footer = """
Repository hosted at ([url="https://github.com/kit-solent/chess"]github.com/kit-solent/chess[/url])

© Max Lang ([url="https://github.com/kit-solent"]github.com/kit-solent[/url]) 2024"""
	$main/body/about/p/t/About/About.text = content + footer

	# setup the tabs dictionary
	var counter = 0
	for i in $main/body/body.get_children():
		tabs[i.name] = counter
		counter += 1

	$main/body/body.current_tab = tabs["joinhost"]

	# create_tween() instead of get_tree().create_tween() binds the tween to this node.
	# this prevents errors when this node is freed (on scene changes).
	var godot_tween = create_tween()
	var chess_tween = create_tween()
	var loop_time = 1

	godot_tween.set_loops()  # no arguments means run forever.
	chess_tween.set_loops()

	# Both back
	godot(godot_tween, loop_time, false)
	chess(chess_tween, loop_time, false)
	# Godot forward
	godot(godot_tween, loop_time, true)
	chess(chess_tween, loop_time, false)
	# Godot back
	godot(godot_tween, loop_time, false)
	chess(chess_tween, loop_time, false)
	# Chess forward
	godot(godot_tween, loop_time, false)
	chess(chess_tween, loop_time, true)
	# Chess back
	godot(godot_tween, loop_time, false)
	chess(chess_tween, loop_time, false)
	# Both forward
	godot(godot_tween, loop_time, true)
	chess(chess_tween, loop_time, true)
	# Both stay
	godot(godot_tween, loop_time, true)
	chess(chess_tween, loop_time, true)

	# connect the signals from Core
	Core.peer_connected.connect(_peer_connected)
	Core.connected_to_server.connect(_connected_to_server)
	Core.connection_failed.connect(_connection_failed)

	Core.username_received.connect(_username_received)

	Core.backspace.connect(_backspace)

	# if we are here because the server quit then inform the user of this.
	if Core.returning_because_server_quit:
		$main/body/body/joinhost/joinhost/return_reason.show()


# Title animation stuff
func godot(tween, time, forward = true):
	"""
	Animate the Godot part of the logo.
	"""
	tween.tween_property(
		%godot_title_label,
		"modulate",
		Color(%godot_title_label.modulate, 1.0 if forward else 0.0),
		time
	)


func chess(tween, time, forward = true):
	"""
	Animate the Chess part of the logo.
	"""
	tween.tween_property(
		%chess_title_label,
		"modulate",
		Color(%chess_title_label.modulate, 1.0 if forward else 0.0),
		time
	)


func reset_fields():
	"""
	Reset all the join code entry fields to empty and focus the first one.
	"""
	$main/body/body/join/v_box_container/join_code_field/line_edit1.grab_focus()
	$main/body/body/join/v_box_container/join_code_field/line_edit1.text = ""
	$main/body/body/join/v_box_container/join_code_field/line_edit2.text = ""
	$main/body/body/join/v_box_container/join_code_field/line_edit3.text = ""
	$main/body/body/join/v_box_container/join_code_field/line_edit4.text = ""


func _peer_connected(id):
	"""
	Called whenever a new peer connects. Add them to the list.
	"""
	if is_host:
		player_menu.get_node("default_message").hide()
		var new = load("res://client_entry.tscn").instantiate()
		new.set_text("<USER: " + str(id) + ">")  # <USER: 123id678> is a placeholder until the username is sent through.
		new.name = str(id)
		new.click.connect(_click.bind(id))
		player_menu.add_child(new)


func _click(id):
	"""
	Called whenever the start game button is clicked on a client_entry.
	Is passed the id of the client as an argument.
	"""
	var playing_as_white: bool
	if %playas.selected == 0:
		playing_as_white = true if RandomNumberGenerator.new().randi_range(0, 1) == 0 else false
	elif %playas.selected == 1:
		playing_as_white = true
	else:
		playing_as_white = false
	for i in Core.connected_peers:
		if i == id:
			start_game.rpc_id(i, not playing_as_white)
		else:
			get_denied.rpc_id(i)
	start_game(playing_as_white)


func _connected_to_server():
	"""
	Called on a client when it successfully connects to the server.
	"""
	if $main/body/body.current_tab == tabs["wait_for_host_connection"]:
		$main/body/body.current_tab = tabs["wait_for_host_start"]


func _connection_failed():
	"""
	Called on a client when it fails to connect to the server for any reason.
	This could be because of a network issue or because the join code is invalid.
	"""
	if $main/body/body.current_tab == tabs["wait_for_host_connection"]:
		$main/body/body.current_tab = tabs["join"]
	$main/body/body/join/v_box_container/label.text = "Connection Failed\nCheck that you have entered the join code correctly and that your internet connection is stable and try again."
	$main/body/body/join/v_box_container/label.hide()
	await get_tree().create_timer(0.1).timeout
	$main/body/body/join/v_box_container/label.show()


func _username_received(username, id):
	"""
	Called when a username is recieved.
	"""
	if multiplayer.is_server():
		player_menu.get_node(str(id)).set_text(username)


@rpc("reliable")
func start_game(playing_as_white):
	"""
	Called when the host starts the game.
	"""
	Core.playing_as_white = playing_as_white
	get_tree().change_scene_to_file("res://board.tscn")


@rpc("reliable")
func get_denied():
	"""
	Called when the host starts a game with someone else.
	"""
	reset_fields()
	$main/body/body.current_tab = tabs["join"]
	$main/body/body/join/v_box_container/label.text = "Host has started a game with someone else."


# these variables are the join code entry boxs
@onready var box1 = %join_code_field/line_edit1
@onready var box2 = %join_code_field/line_edit2
@onready var box3 = %join_code_field/line_edit3
@onready var box4 = %join_code_field/line_edit4

# valid join code characters are only leters of either case.
const CODE_CHARS = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"


func fix_text(label_num, text = null):
	"""
	Changes the text in the given label to be valid.
	"""
	# get the label node from the index.
	var label = [box1, box2, box3, box4][label_num]

	# if text is not provided default to the label's text.
	if not text:
		text = label.text

	# record the caret position for later use.
	var caret_pos = label.caret_column
	var new = ""
	var carry = 0

	# loop over
	for i in range(len(text)):
		if text[i] in CODE_CHARS:
			new += text[i].to_lower()
		elif text[i] == " ":
			carry = text.substr(i + 1)
			break
		else:
			$main/body/body/join/v_box_container/label.text = "Join code must contain only letters and spaces."
			caret_pos -= 1
	label.text = new
	if new:
		empty[label_num] = false
	label.caret_column = caret_pos

	if typeof(carry) == TYPE_STRING and label_num != 3:
		[box1, box2, box3, box4][label_num + 1].grab_focus()
		fix_text(label_num + 1, carry)


# the following 4 functions use fix_text to fix the text on a label
# when it is edited.
func _on_line_edit_1_text_changed(_new_text):
	fix_text(0)


func _on_line_edit_2_text_changed(_new_text):
	fix_text(1)


func _on_line_edit_3_text_changed(_new_text):
	fix_text(2)


func _on_line_edit_4_text_changed(_new_text):
	fix_text(3)


# the following 4 functions shift the focus right when the enter key is pressed.
func _on_line_edit_1_text_submitted(_new_text):
	box2.grab_focus()


func _on_line_edit_2_text_submitted(_new_text):
	box3.grab_focus()


func _on_line_edit_3_text_submitted(_new_text):
	box4.grab_focus()


# this is the last box so try and connect when submitted.
func _on_line_edit_4_text_submitted(_new_text):
	$main/body/body.current_tab = tabs["wait_for_host_connection"]
	Core.create_client(
		Core.code_to_ip(box1.text + " " + box2.text + " " + box3.text + " " + box4.text)
	)


var empty = [false, false, false, false]  # tracks if the boxes were already empty before backspace was pressed.


func _backspace():
	"""
	This is called whenever the backspace key is pressed and the join code fields have focus.
	It moves the curser/focus to the previous box if the current box is empty. This makes navigating
	the UI easyer. 
	"""
	if $main/body/body.current_tab == tabs["join"]:
		var box = null
		for i in [box1, box2, box3, box4]:
			if i.has_focus():
				box = i
		if not box:
			return  # no box has focus
		if box.text == "":  # if the box is empty
			if box == box1:
				if empty[0]:
					return
				else:
					empty[0] = true
			if box == box2:
				if empty[1]:
					box1.grab_focus()
				else:
					empty[1] = true
			if box == box3:
				if empty[2]:
					box2.grab_focus()
				else:
					empty[2] = true
			if box == box4:
				if empty[3]:
					box3.grab_focus()
				else:
					empty[3] = true


func _on_join_button_down():
	"""
	This is called when the join button is pressed and moves the UI to the join code
	entering screen.
	"""
	$main/body/body.current_tab = tabs["join"]
	%join_code_field/line_edit1.grab_focus()
	Core.username = %username_lineedit.text


# variable to track if we are the host or not.
var is_host


func _on_host_button_down():
	"""
	Called when the host button is clicked and creates a server.
	"""
	is_host = true
	$main/body/body.current_tab = tabs["host"]
	Core.create_server()
	var code = Core.ip_to_code(Core.ip_address)
	%join_code.text = code.replace(" ", "\n")
	$main/body/body/host/settings/margin_container/v_box_container/host_username.text = (
		"Your username is:\n" + %username_lineedit.text
	)
	Core.username = %username_lineedit.text


func _on_about_meta_clicked(meta):
	"""
	Called when a link in the UI is clicked.
	Check the link is meant to be opened and then open it.
	"""
	if (
		meta
		in [  # only open the link if it is one of the following.
			"https://fonts.google.com/specimen/Ubuntu",
			"https://opengameart.org/content/pixel-chess-pieces",
			"https://www.svgrepo.com/svg/477430/coin-toss-3",
			"https://godotengine.org",
			"https://github.com/kit-solent",
			"https://github.com/kit-solent/chess"
		]
	):
		# Use the OS class to open the link in the systems default browser.
		OS.shell_open(meta)


func _on_about_button_down():
	"""
	Called when the about button is clicked to toggle the visability of the about panel.
	"""
	$main/body/about.visible = not $main/body/about.visible


# these are the characters allowed in a username.
const ALLOWED_CHARS = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz123567890 _-."


func _on_line_edit_text_changed(new_text: String):
	"""
	Called whenever the text is changed on the username lineedit. This ensures that the username is valid.
	"""
	var pos = %username_lineedit.caret_column
	var allowed = ""
	for i in new_text:
		if i in ALLOWED_CHARS:
			allowed += i
		else:
			pos -= 1
	%join_button.disabled = not len(allowed) > 0
	%join_button.focus_mode = FOCUS_ALL if len(allowed) > 0 else FOCUS_NONE
	%host_button.disabled = not len(allowed) > 0
	%host_button.focus_mode = FOCUS_ALL if len(allowed) > 0 else FOCUS_NONE
	%username_lineedit.text = allowed
	%username_lineedit.caret_column = pos
