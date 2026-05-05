extends TextureButton

@export var input: LineEdit
@export var mainControl: Control

func _on_pressed() -> void:
	print(input.text)
	mainControl.join_game(input.text)

func _on_button_down() -> void:
	$AnimationPlayer.play("Down")


func _on_button_up() -> void:
	$AnimationPlayer.play_backwards("Down")
