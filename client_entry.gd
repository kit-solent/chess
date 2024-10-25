extends HBoxContainer

# emmitted when the start game button is clicked on this client_entry.
signal click


func set_text(text):
	"""
	Changes the text on the username label.
	"""
	# set the text on the label.
	$username.text = text


func _on_button_button_down():
	"""
	Called whenever the start game button is clicked on this client_entry.
	"""
	click.emit()
