extends Control

@export var mainWindow: Control
@export var mainControl: Control
@export var windowAnimator: AnimationPlayer
@export var colorRect: ColorRect

func _on_create_pressed() -> void:
	mainControl.create_game()
	mainWindow.visible = false
	visible = true
	

func _on_control_http_response(response: Variant) -> void:
	print(response)
	if response.has("logged_in"):
		pass
		windowAnimator.play_backwards("In")
		await get_tree().create_timer(0.4).timeout
		colorRect.visible = false
	elif response.has("game_id"):
		$VBoxContainer/Code.text = str(response["game_id"])
