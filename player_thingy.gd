extends HBoxContainer

signal click

func set_text(text):
	$label.text=text

func _on_button_button_down():
	click.emit()
