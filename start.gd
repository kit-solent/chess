extends Control

@onready var player_menu = %player_join_game_thingy
var tabs:Dictionary # a dictionary of tabs in the form "tab name": tab index. Used to look up tabs by name.

func _ready():
	var counter = 0
	for i in $main/body/body.get_children():
		tabs[i.name] = counter
		counter += 1
	
	$main/body/body.current_tab=tabs["joinhost"]
	
	# create_tween() instead of get_tree().create_tween() binds the tween to this node.
	# this prevents errors when this node is freed (on scene changes).
	var godot_tween=create_tween()
	var chess_tween=create_tween()
	var loop_time=1

	godot_tween.set_loops() # no arguments means run forever.
	chess_tween.set_loops()

	# Both back
	godot(godot_tween,loop_time,false)
	chess(chess_tween,loop_time,false)
	# Godot forward
	godot(godot_tween,loop_time,true)
	chess(chess_tween,loop_time,false)
	# Godot back
	godot(godot_tween,loop_time,false)
	chess(chess_tween,loop_time,false)
	# Chess forward
	godot(godot_tween,loop_time,false)
	chess(chess_tween,loop_time,true)
	# Chess back
	godot(godot_tween,loop_time,false)
	chess(chess_tween,loop_time,false)
	# Both forward
	godot(godot_tween,loop_time,true)
	chess(chess_tween,loop_time,true)
	# Both stay
	godot(godot_tween,loop_time,true)
	chess(chess_tween,loop_time,true)
	
	Core.peer_connected.connect(_peer_connected)
	Core.peer_disconnected.connect(_peer_disconnected)
	Core.connected_to_server.connect(_connected_to_server)
	Core.connection_failed.connect(_connection_failed)
	Core.server_disconnected.connect(_server_disconnected)
	
	Core.username_recieved.connect(_username_recieved)
	
	Core.backspace.connect(_backspace)

# Title animation stuff
func godot(tween,time,forward=true):
	tween.tween_property(%godot_title_label,"modulate",Color(%godot_title_label.modulate,1.0 if forward else 0.0),time)

func chess(tween,time,forward=true):
	tween.tween_property(%chess_title_label,"modulate",Color(%chess_title_label.modulate,1.0 if forward else 0.0),time)

func reset_fields():
	$main/body/body/join/v_box_container/join_code_field/line_edit1.grab_focus()
	$main/body/body/join/v_box_container/join_code_field/line_edit1.text=""
	$main/body/body/join/v_box_container/join_code_field/line_edit2.text=""
	$main/body/body/join/v_box_container/join_code_field/line_edit3.text=""
	$main/body/body/join/v_box_container/join_code_field/line_edit4.text=""

func _peer_connected(id):
	if is_host:
		player_menu.get_node("default_message").hide()
		var new = load("res://player_thingy.tscn").instantiate()
		new.set_text("<USER: "+str(id)+">") # <USER: 123id678> is a placeholder untill the username is sent through.
		new.name = str(id)
		new.click.connect(_click.bind(id))
		player_menu.add_child(new)

@onready var thingy = $main/body/body/host/settings/margin_container/v_box_container/panel_container/margin_container/playas/option_button
func _click(id):
	var playing_as_white:bool
	if thingy.selected == 0:
		playing_as_white = true if RandomNumberGenerator.new().randi_range(0,1)==0 else false
	elif thingy.selected == 1:
		playing_as_white = true
	else:
		playing_as_white = false
	for i in Core.connected_peers:
		if i==id:
			start_game.rpc_id(i, not playing_as_white)
		else:
			get_denied.rpc_id(i)
	start_game(playing_as_white)

func _peer_disconnected(_id):
	pass

func _connected_to_server():
	if $main/body/body.current_tab == tabs["wait_for_host_connection"]:
		$main/body/body.current_tab = tabs["wait_for_host_start"]

func _connection_failed():
	if $main/body/body.current_tab == tabs["wait_for_host_connection"]:
		$main/body/body.current_tab = tabs["join"]
	$main/body/body/join/v_box_container/label.text = "Connection Failed\nCheck that you have entered the join code correctly and that your internet connection is stable and try again."
	$main/body/body/join/v_box_container/label.hide()
	await get_tree().create_timer(0.1).timeout
	$main/body/body/join/v_box_container/label.show()

func _server_disconnected():
	pass

func _username_recieved(username,id):
	if multiplayer.is_server():
		player_menu.get_node(str(id)).set_text(username)

@rpc("reliable")
func start_game(playing_as_white):
	Core.playing_as_white=playing_as_white
	get_tree().change_scene_to_file("res://board.tscn")

@rpc("reliable")
func get_denied():
	reset_fields()
	$main/body/body.current_tab=tabs["join"]
	$main/body/body/join/v_box_container/label.text="Host has started a game with someone else."

@onready var box1 = %join_code_field/line_edit1
@onready var box2 = %join_code_field/line_edit2
@onready var box3 = %join_code_field/line_edit3
@onready var box4 = %join_code_field/line_edit4

const CODE_CHARS = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
var current_code = ""

func fix_text(label_num,text=null):
	var label = [box1,box2,box3,box4][label_num]
	if not text:
		text = label.text
	var caret_pos = label.caret_column
	var new = ""
	var carry = 0
	for i in range(len(text)):
		if text[i] in CODE_CHARS:
			new += text[i].to_lower()
		elif text[i] == " ":
			carry = text.substr(i+1)
			break
		else:
			$main/body/body/join/v_box_container/label.text = "Join code must contain only letters and spaces."
			caret_pos -= 1
	label.text=new
	if new:
		empty[label_num]=false
	label.caret_column=caret_pos
	
	if typeof(carry) == TYPE_STRING and label_num != 3:
		[box1,box2,box3,box4][label_num+1].grab_focus()
		fix_text(label_num+1,carry)

func _on_line_edit_1_text_changed(_new_text):
	fix_text(0)

func _on_line_edit_2_text_changed(_new_text):
	fix_text(1)

func _on_line_edit_3_text_changed(_new_text):
	fix_text(2)

func _on_line_edit_4_text_changed(_new_text):
	fix_text(3)

func _on_line_edit_1_text_submitted(_new_text):
	box2.grab_focus()

func _on_line_edit_2_text_submitted(_new_text):
	box3.grab_focus()

func _on_line_edit_3_text_submitted(_new_text):
	box4.grab_focus()

func _on_line_edit_4_text_submitted(_new_text):
	$main/body/body.current_tab = tabs["wait_for_host_connection"]
	Core.create_client(Core.code_to_ip(box1.text+" "+box2.text+" "+box3.text+" "+box4.text))

var empty = [false,false,false,false] # tracks if the boxs were already empty before backspace was pressed.
func _backspace():
	if $main/body/body.current_tab == tabs["join"]:
		var box = null
		for i in [box1,box2,box3,box4]:
			if i.has_focus():
				box = i
		if not box:
			return # no box has focus
		if box.text == "": # if the box is empty
			if box == box1:
				if empty[0]:
					return
				else:
					empty[0]=true
			if box == box2:
				if empty[1]:
					box1.grab_focus()
				else:
					empty[1]=true
			if box == box3:
				if empty[2]:
					box2.grab_focus()
				else:
					empty[2]=true
			if box == box4:
				if empty[3]:
					box3.grab_focus()
				else:
					empty[3]=true

func _on_join_button_down():
	$main/body/body.current_tab=tabs["join"]
	%join_code_field/line_edit1.grab_focus()
	Core.username = %username_lineedit.text

var is_host
func _on_host_button_down():
	is_host = true
	$main/body/body.current_tab=tabs["host"]
	Core.create_server()
	var code=Core.ip_to_code(Core.ip_address)
	%join_code.text=code.replace(" ","\n")
	$main/body/body/host/settings/margin_container/v_box_container/host_username.text="Your username is:\n"+%username_lineedit.text
	Core.username = %username_lineedit.text

func _on_about_meta_clicked(meta):
	if meta in ["https://fonts.google.com/specimen/Ubuntu","https://opengameart.org/content/pixel-chess-pieces","https://www.svgrepo.com/svg/477430/coin-toss-3"]:
		OS.shell_open(meta)

func _on_about_button_down():
	pass # TODO

const ALLOWED_CHARS="ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz123567890 _-."
func _on_line_edit_text_changed(new_text:String):
	var pos=%username_lineedit.caret_column
	var allowed=""
	for i in new_text:
		if i in ALLOWED_CHARS:
			allowed+=i
		else:
			pos-=1
	%join_button.disabled=not len(allowed)>0
	%join_button.focus_mode=FOCUS_ALL if len(allowed)>0 else FOCUS_NONE
	%host_button.disabled=not len(allowed)>0
	%host_button.focus_mode=FOCUS_ALL if len(allowed)>0 else FOCUS_NONE
	%username_lineedit.text=allowed
	%username_lineedit.caret_column=pos

func _on_time_controls_enabled_button_down():
	%easyhide.visible = not %easyhide.visible
	if %easyhide.visible:
		%time_controls_enabled.text="Enabled"
	else:
		%time_controls_enabled.text="No Time Controls"
