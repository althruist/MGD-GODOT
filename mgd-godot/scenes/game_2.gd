extends Control

var numbers = []
var correctNumber
var round = 0
var correct_node: Control

func _button_pressed(node: Control, value: int): # gets the '$"."' and 'value' from earlier

	if value == correctNumber: # Checks if it's the correct number
		Input.vibrate_handheld(100, 0.5) # cool fancy stuff
		node.get_node("AnimationPlayer").play("Correct")
		await get_tree().create_timer(0.4).timeout
		node.get_node("AnimationPlayer").play("Idle")
		startRound() # starts new round
	else: # if incorrect
		node.get_node("AnimationPlayer").play("Incorrect") # more fancy stuff
		correct_node.get_node("AnimationPlayer").play("Correct") # can you tell i like animating?
		_say(str(correctNumber)) # says the correct number
		Input.vibrate_handheld(300, 1)

		await get_tree().create_timer(0.4).timeout

		node.get_node("AnimationPlayer").play("Idle") # ... more fancy stuff
		correct_node.get_node("AnimationPlayer").play("Idle")

func _say(text: String):
	DisplayServer.tts_speak(text, "", 100, 1.5, 0.8, 0, true)


func shuffleNumbers() -> void:
	numbers.clear()
	correct_node = null

	var selectables = get_tree().get_nodes_in_group("Selectable")

	correct_node = selectables[randi_range(0, selectables.size() - 1)]
	correctNumber = randi_range(0, 100)

	_say(str(correctNumber))
	print("correct number:", correctNumber)
	
	for selectable in selectables: # this is every button
		if selectable.buttonPressed.is_connected(_button_pressed): # checks if the connection already exists
			selectable.buttonPressed.disconnect(_button_pressed) # if it does, it disconnects so there's no weird issues
		var generatedNum = randi_range(0, 100)

		while numbers.has(generatedNum):
			generatedNum = randi_range(0, 100)

		numbers.append(generatedNum)

		if selectable == correct_node:
			generatedNum = correctNumber

		selectable.value = generatedNum
		selectable.get_node("TextureButton/Label").text = str(generatedNum)
		selectable.buttonPressed.connect(_button_pressed) # reconnects to the function _button_pressed

func startRound():
	if round == 2:
		MessageScreen.processor(true, "Finished!")
		await get_tree().create_timer(3).timeout
		MessageScreen.processor(false, "")
		TransitionScreen.processor(true, false, load("res://scenes/Menu.tscn"), $".")
		return

	shuffleNumbers()
	round += 1

func _ready() -> void:
	# On some phones, tts_get_voices() returns empty until fully initialized
	while DisplayServer.tts_get_voices().is_empty():
		await get_tree().create_timer(0.1).timeout
		print("Waiting for TTS engine...")
	await get_tree().create_timer(2).timeout
	startRound()


func _on_replay_button_down() -> void:
	$Replay/AnimationPlayer.play("Down")


func _on_replay_button_up() -> void:
	$Replay/AnimationPlayer.play("Up")


func _on_replay_pressed() -> void:
	_say(str(correctNumber))
