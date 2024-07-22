extends Control

func _ready():
	$main/body/body.current_tab=0
	
	var godot_tween=get_tree().create_tween()
	var chess_tween=get_tree().create_tween()
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

@onready var box1=%join_code_field/line_edit1
@onready var box2=%join_code_field/line_edit2
@onready var box3=%join_code_field/line_edit3
@onready var box4=%join_code_field/line_edit4

var current_code=""
func _process(delta):
	#if get_viewport().gui_get_focus_owner() is box1:
	#	pass
	pass

const CODE_CHARS = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
func fix_text(text):
	var new = ""
	for i in text:
		if i in CODE_CHARS:
			new += i.to_lower()
		else:
			$main/body/body/join/v_box_container/label.text = "Join code must contain only letters."
	return new

func _on_line_edit_1_text_changed(new_text):
	var text = new_text.split(" ")
	if len(text) > 1:
		# pass on all text after the first space to the next box
		_on_line_edit_2_text_changed("".join(text.slice(1)))
		%join_code_field/line_edit2.grab_focus()
	%join_code_field/line_edit1.text = fix_text(text[0])

func _on_line_edit_2_text_changed(new_text):
	var text = new_text.split(" ")
	if len(text) > 1:
		# pass on all text after the first space to the next box
		_on_line_edit_2_text_changed("".join(text.slice(1)))
		%join_code_field/line_edit3.grab_focus()
	%join_code_field/line_edit2.text = fix_text(text[0])

func _on_line_edit_3_text_changed(new_text):
	var text = new_text.split(" ")
	if len(text) > 1:
		# pass on all text after the first space to the next box
		_on_line_edit_2_text_changed("".join(text.slice(1)))
		%join_code_field/line_edit4.grab_focus()
	%join_code_field/line_edit3.text = fix_text(text[0])

func _on_line_edit_4_text_changed(new_text):
	%join_code_field/line_edit3.text = fix_text(new_text)


func _on_line_edit_1_focus_exited():
	pass
	#if %join_code_field/line_edit1.text.to_lower() in Co

func _on_line_edit_2_focus_exited():
	pass # Replace with function body.

func _on_line_edit_3_focus_exited():
	pass # Replace with function body.

func _on_line_edit_4_focus_exited():
	pass # Replace with function body.


# Title animation stuff
func godot(tween,time,forward=true):
	tween.tween_property(%godot_title_label,"modulate",Color(%godot_title_label.modulate,1.0 if forward else 0.0),time)

func chess(tween,time,forward=true):
	tween.tween_property(%chess_title_label,"modulate",Color(%chess_title_label.modulate,1.0 if forward else 0.0),time)


func _on_join_button_down():
	$main/body/body.current_tab=2
	%join_code_field/line_edit1.grab_focus()

func _on_host_button_down():
	$main/body/body.current_tab=1
	Core.create_server()
	var code=Core.ip_to_code(Core.ip_address)
	%join_code.text=code.replace(" ","\n")
	$main/body/body/host/settings/margin_container/v_box_container/host_username.text="Your username is: "+%username_lineedit.text

func _on_about_meta_clicked(meta):
	if meta in ["https://fonts.google.com/specimen/Ubuntu","https://opengameart.org/content/pixel-chess-pieces","https://www.svgrepo.com/svg/477430/coin-toss-3"]:
		OS.shell_open(meta)

func _on_about_button_down():
	pass # Replace with function body.

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

