extends Control

@export var value: int # This is the assigned number
signal buttonPressed(node: Control,value:int) # Creation of the signal, expects node of type Control and value of type int

func _on_texture_button_button_down() -> void:
	$AnimationPlayer.play("Down")


#func _on_texture_button_button_up() -> void:
	#$AnimationPlayer.play("Correct")
	#await get_tree().create_timer(0.4).timeout
	#$AnimationPlayer.play("Idle")


func _on_texture_button_pressed() -> void: # when button pressed, go figure
	emit_signal("buttonPressed",$".", value) # Emits the signal "buttonPressed", and sends itself ($".") and value
