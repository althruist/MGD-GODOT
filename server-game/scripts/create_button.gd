extends TextureButton

@export var colorRect: ColorRect

func _on_pressed() -> void:
	colorRect.visible = false

func _on_button_down() -> void:
	$AnimationPlayer.play("Down")


func _on_button_up() -> void:
	$AnimationPlayer.play_backwards("Down")
