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

func _on_join_code_text_changed(new_text):
	pass # Replace with function body.
