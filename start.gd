extends Control

func _ready():
	var godot_tween=get_tree().create_tween()
	var chess_tween=get_tree().create_tween()
	var loop_time=1

	godot_tween.set_loops() # no arguments means run forever.
	chess_tween.set_loops()

	# Both back
	godot_tween.tween_property($v_box_container/head/row/control/godot,"modulate",Color($v_box_container/head/row/control/godot.modulate,0.0),loop_time)
	chess_tween.tween_property($v_box_container/head/row/control/chess,"modulate",Color($v_box_container/head/row/control/chess.modulate,0.0),loop_time)

	# Godot forward, chess stays back another loop
	godot_tween.tween_property($v_box_container/head/row/control/godot,"modulate",Color($v_box_container/head/row/control/godot.modulate,1.0),loop_time)
	chess_tween.tween_property($v_box_container/head/row/control/chess,"modulate",Color($v_box_container/head/row/control/chess.modulate,0.0),loop_time)

	# Chess forward, Godot stays forward another loop
	godot_tween.tween_property($v_box_container/head/row/control/godot,"modulate",Color($v_box_container/head/row/control/godot.modulate,1.0),loop_time)
	chess_tween.tween_property($v_box_container/head/row/control/chess,"modulate",Color($v_box_container/head/row/control/chess.modulate,1.0),loop_time)

	# Both wait forward for a loop
	godot_tween.tween_property($v_box_container/head/row/control/godot,"modulate",Color($v_box_container/head/row/control/godot.modulate,1.0),loop_time)
	chess_tween.tween_property($v_box_container/head/row/control/chess,"modulate",Color($v_box_container/head/row/control/chess.modulate,1.0),loop_time)

	# Godot back, Chess stays forward another loop
	godot_tween.tween_property($v_box_container/head/row/control/godot,"modulate",Color($v_box_container/head/row/control/godot.modulate,0.0),loop_time)
	chess_tween.tween_property($v_box_container/head/row/control/chess,"modulate",Color($v_box_container/head/row/control/chess.modulate,1.0),loop_time)

	# then back to the top of the loop

	# # Godot forward, Chess back
	# godot_tween.tween_property($v_box_container/head/row/control/godot,"modulate",Color($v_box_container/head/row/control/godot.modulate,1.0),loop_time)
	# chess_tween.tween_property($v_box_container/head/row/control/chess,"modulate",Color($v_box_container/head/row/control/chess.modulate,0.0),loop_time)

	# # Chess forward, Godot back
	# chess_tween.tween_property($v_box_container/head/row/control/chess,"modulate",Color($v_box_container/head/row/control/chess.modulate,1.0),loop_time)
	# godot_tween.tween_property($v_box_container/head/row/control/godot,"modulate",Color($v_box_container/head/row/control/godot.modulate,0.0),loop_time)

func _process(delta):
	pass

func _on_join_button_down():
	Core.create_client(Core.code_to_ip($join_code.text))
	$my_id.text=str(multiplayer.get_unique_id())

func _on_host_button_down():
	Core.create_server()
	$my_id.text=str(multiplayer.get_unique_id())
	$join_code.text=Core.ip_to_code(Core.ip_address)

func _on_about_meta_clicked(meta):
	if meta in ["https://fonts.google.com/specimen/Ubuntu","https://opengameart.org/content/pixel-chess-pieces","https://www.svgrepo.com/svg/477430/coin-toss-3"]:
		OS.shell_open(meta)

func _on_about_button_down():
	pass # Replace with function body.

const ALLOWED_CHARS="ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz "
func _on_line_edit_text_changed(new_text:String):
	var pos=$v_box_container/body/joinhost/margin_container/joinhost/margin_container/panel_container/margin_container/h_box_container/margin_container/line_edit
	pos=pos.caret_column
	var allowed=""
	for i in new_text:
		if i in ALLOWED_CHARS:
			allowed+=i
		else:
			pos-=1
	$v_box_container/body/joinhost/margin_container/joinhost/joinhost/button.disabled=not len(allowed)>0
	$v_box_container/body/joinhost/margin_container/joinhost/joinhost/button2.disabled=not len(allowed)>0
	$v_box_container/body/joinhost/margin_container/joinhost/margin_container/panel_container/margin_container/h_box_container/margin_container/line_edit.text=allowed
	$v_box_container/body/joinhost/margin_container/joinhost/margin_container/panel_container/margin_container/h_box_container/margin_container/line_edit.caret_column=pos
