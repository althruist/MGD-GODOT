extends ColorRect

# 'visible' is if the transition screen is visible or not
# 'restart' checks if the scene is being restarted or if there's a new scene to be loaded
# 'scene' is the scene that you want to load
# 'sceneRoot' is the root of each scene, I use this to give the transition a zoom effect when animating

# also note that i gave the parameters default values to make them optional

## transition handler, not sure what i can write lol
func processor(visible: bool, restart: bool = false, scene: PackedScene = null, sceneRoot: Control = null) -> void:
	if visible: # checks if visible
		$".".move_to_front() # moves transition to the bottom of the hierachy to stop people from pressing anything when transitioning
		$AnimationPlayer.play("Show") # fancy stuff
		$AudioStreamPlayer.stream = load("res://audio/interactions/transition.mp3")
		$AudioStreamPlayer.play()
		if sceneRoot: # if i passed the scene's root
			var tween = get_tree().create_tween() # animation, more fancy nancy
			tween.tween_property(sceneRoot, "scale", Vector2(5,5), 0.4).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
		await $AnimationPlayer.animation_finished
		if restart: # if restart
			get_tree().reload_current_scene()
		if scene != null: # if there's a scene passed
			get_tree().change_scene_to_packed(scene)
		await get_tree().create_timer(2.0).timeout
		processor(false) # recursive, switches the transition screen off
	else: # if not visible
		$AnimationPlayer.play_backwards("Show")
