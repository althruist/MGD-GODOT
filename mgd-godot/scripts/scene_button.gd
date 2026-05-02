extends TextureButton

enum Navigate {
	BACK,
	RESTART,
}

@export var navigate: Navigate
@export var root: Control

func _on_button_down() -> void:
	$"AnimationPlayer".play("SceneButton/Down")

func _on_button_up() -> void:
	$"AnimationPlayer".play("SceneButton/Up")

func _on_pressed() -> void:
	Input.vibrate_handheld(2000, 1)
	if navigate == Navigate.RESTART:
		TransitionScreen.processor(true, true, null, root)
	elif navigate == Navigate.BACK:
		TransitionScreen.processor(true, false, load("res://scenes/Menu.tscn"), root)
