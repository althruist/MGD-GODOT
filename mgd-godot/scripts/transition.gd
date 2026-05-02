extends ColorRect

## transition handler, not sure what i can write lol
func processor(visible: bool, restart: bool = false, scene: PackedScene = null, sceneRoot: Control = null) -> void:
	if visible:
		$".".move_to_front()
		$AnimationPlayer.play("Show")
		if sceneRoot:
			var tween = get_tree().create_tween()
			tween.tween_property(sceneRoot, "scale", Vector2(5,5), 0.4).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
		await $AnimationPlayer.animation_finished
		if restart:
			get_tree().reload_current_scene()
		if scene != null:
			get_tree().change_scene_to_packed(scene)
		await get_tree().create_timer(2.0).timeout
		processor(false)
	else:
		$AnimationPlayer.play_backwards("Show")
