extends Control

## show or hide message
func processor(visible: bool, text: String) -> void:
	if visible:
		print("showing!")
		$".".move_to_front()
		$ColorRect/AnimationPlayer.play("Message/In")
		$ColorRect/Message.text = text
	else:
		$ColorRect/AnimationPlayer.play_backwards("Message/In")
