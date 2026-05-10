extends Control

@export var main:Control

func _on_button_pressed() -> void:
	main.get_board(main.game_id)
	print("board requested")
