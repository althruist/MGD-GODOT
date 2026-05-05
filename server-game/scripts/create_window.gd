extends Control

@export var mainWindow: Control
@export var mainControl: Control
@export var windowAnimator: AnimationPlayer

func _on_create_pressed() -> void:
	mainControl.create_game()
	mainWindow.visible = false
	visible = true

func _on_control_http_response(response: Variant) -> void:
	print(response)
	if response.has("logged_in"):
		windowAnimator.play_backwards("In")
	elif response.has("game_id"):
		$VBoxContainer/Code.text = str(response["game_id"])
