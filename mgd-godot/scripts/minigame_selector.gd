extends TextureButton

@export var anim_player: AnimationPlayer
@export var scene: PackedScene

var isPressed = false

func _on_button_down() -> void:
	if isPressed: return
	anim_player.play("MainMenuButton/Down")
	$AudioStreamPlayer.stream = load("res://audio/interactions/click.mp3")
	$AudioStreamPlayer.play()
	create_tween().tween_property(get_node("."), "rotation", randf_range(-0.1, 0.1), 0.2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)


func _on_button_up() -> void:
	if isPressed: return
	create_tween().tween_property(get_node("."), "rotation", 0, 0.2)
	anim_player.play("MainMenuButton/Exit")

func _on_pressed() -> void:
	Input.vibrate_handheld(2000, 1)
	isPressed = true
	get_node(".").z_index = 10
	anim_player.play("MainMenuButton/Release")
	TransitionScreen.processor(true, false, scene)
	pass
