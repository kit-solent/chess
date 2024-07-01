extends Control

func _ready():
	pass

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
