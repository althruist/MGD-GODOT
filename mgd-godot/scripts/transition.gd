extends ColorRect

## transition handler, not sure what i can write lol
func processor(visible: bool, scene: PackedScene = null) -> void:
	if visible:
		$AnimationPlayer.play("Show")
		await $AnimationPlayer.animation_finished
		if scene != null:
			get_tree().change_scene_to_packed(scene)
		await get_tree().create_timer(2.0).timeout
		processor(false)
	else:
		$AnimationPlayer.play_backwards("Show")
