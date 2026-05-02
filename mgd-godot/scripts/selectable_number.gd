extends Control

@export var value: int
signal buttonPressed(node: Control,value:int)

func _on_texture_button_button_down() -> void:
	$AnimationPlayer.play("Down")


#func _on_texture_button_button_up() -> void:
	#$AnimationPlayer.play("Correct")
	#await get_tree().create_timer(0.4).timeout
	#$AnimationPlayer.play("Idle")


func _on_texture_button_pressed() -> void:
	emit_signal("buttonPressed",$".", value)
