extends TextureButton

@export var anim_player: AnimationPlayer;
@export var scene: PackedScene
@export var whiteTrans: ColorRect

var isPressed = false

func _on_button_down() -> void:
	if isPressed: return
	anim_player.play("MainMenuButton/Down")
	create_tween().tween_property(get_node("."), "rotation", randf_range(-0.1, 0.1), 0.2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)


func _on_button_up() -> void:
	if isPressed: return
	isPressed = true
	anim_player.play("MainMenuButton/Release")
	create_tween().tween_property(get_node("."), "rotation", 0, 0.2)


func _on_pressed() -> void:
	get_node(".").z_index = 10
	TransitionScreen.processor(true, scene)
	pass
