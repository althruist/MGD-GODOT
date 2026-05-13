extends TextureButton

@export var input: LineEdit
@export var mainControl: Control
@export var colorRect: ColorRect

func _on_pressed() -> void:
	mainControl.join_game(input.text)
	await get_tree().create_timer(0.4).timeout

func _on_button_down() -> void:
	$AnimationPlayer.play("Down")


func _on_button_up() -> void:
	$AnimationPlayer.play_backwards("Down")
