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

# Title animation stuff
func godot(tween,time,forward=true):
	tween.tween_property(%godot_title_label,"modulate",Color(%godot_title_label.modulate,1.0 if forward else 0.0),time)

func chess(tween,time,forward=true):
	tween.tween_property(%chess_title_label,"modulate",Color(%chess_title_label.modulate,1.0 if forward else 0.0),time)


func _on_join_button_down():
	$main/body/body.current_tab=2

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

const ALLOWED_CHARS="ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz123567890 "
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
