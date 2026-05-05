extends TextureButton

func _on_button_down() -> void:
	$AnimationPlayer.play("Down")


func _on_button_up() -> void:
	$AnimationPlayer.play_backwards("Down")
