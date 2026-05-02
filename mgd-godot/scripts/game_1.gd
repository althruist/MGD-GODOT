extends Control

var correctAnswer = null

var round = 0

func generateEquation() -> Array:
	var num1 = randi_range(1,10)
	var num2 = randi_range(1,10)
	var correctAnswer = num1 + num2
	return [num1, num2, correctAnswer]

func setRandomColors() -> void:
	var buttons = get_tree().get_nodes_in_group("Colorize")
	for button in buttons:
		button.self_modulate = Color.from_hsv(randf(), 1, 0.9)

func setAnswers(correct_answer: int) -> void:
	var buttons = get_tree().get_nodes_in_group("Selectable")
	correctAnswer = correct_answer
	
	var answers = []
	answers.append(correct_answer)

	while answers.size() < buttons.size():
		var wrong = randi_range(1, 20)
		
		if wrong != correct_answer and not answers.has(wrong):
			answers.append(wrong)

	answers.shuffle()
	for i in range(buttons.size()):
		buttons[i].get_node("Label").text = str(answers[i])

func onAnswersProvided(value):
	if correctAnswer == value:
		$DropArea/AnimationPlayer.play("Correct")
		$DropArea/Label.text = "Correct! :)"
		Input.vibrate_handheld(100, 1)
		await get_tree().create_timer(0.15).timeout
		Input.vibrate_handheld(100, 0.5)
		await get_tree().create_timer(0.35).timeout
		startRound();
	else:
		$DropArea/AnimationPlayer.play("Incorrect")
		$DropArea/Label.text = "Incorrect! :("
		Input.vibrate_handheld(800, 1)
		await get_tree().create_timer(0.5).timeout
	$DropArea/Label.text = "Drop your\nanswer here!"

func startRound():
	if round == 4:
		MessageScreen.processor(true, "Finished!")
		await get_tree().create_timer(3).timeout
		MessageScreen.processor(false, "")
		TransitionScreen.processor(true, false, load("res://scenes/Menu.tscn"), $".")
		return
	var generatedNums = generateEquation()
	$Equation/HBoxContainer/Number1/Label.text = str(generatedNums[0])
	$Equation/HBoxContainer/Number2/Label.text = str(generatedNums[1])
	setAnswers(generatedNums[2])
	setRandomColors()
	round += 1
	$Progress/HBoxContainer.get_node("Spot" + str(round)).self_modulate = Color("#6f9d70")
	var vfx = TextureRect.new()
	vfx.texture = load("res://images/ui/timespot.png")
	vfx.size = $Progress/HBoxContainer.get_node("Spot1").size
	vfx.position = $Progress/HBoxContainer.get_node("Spot" + str(round)).global_position
	vfx.pivot_offset_ratio = Vector2(0.5, 0.5)
	vfx.self_modulate = Color("8fc990ff")
	var tween = get_tree().create_tween()
	var tween2 = get_tree().create_tween()
	tween.tween_property(vfx, "scale", Vector2(3, 3), 1).set_trans(Tween.TRANS_CIRC).set_ease(Tween.EASE_OUT)
	tween2.tween_property(vfx, "self_modulate", Color("#709e7100"), 1).set_trans(Tween.TRANS_CIRC).set_ease(Tween.EASE_OUT)
	
	add_child(vfx)

func _ready() -> void:
	$DropArea.answer_provided.connect(onAnswersProvided)
	startRound()
