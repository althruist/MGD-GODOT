extends NinePatchRect

signal answer_provided(value: int)

func _can_drop_data(at_position: Vector2, data: Variant) -> bool: # This just checks if whatever is grabbed
	return data is Dictionary and data.get("type") == "answer" #    should be listened to by the drop area

func _drop_data(at_position: Vector2, data: Variant) -> void: # On drop, this gets the data from _get_drag_data from the other script
	var value = data["value"] # This specifically gets the 'value' from that struct/object in the other script, which is the number
	emit_signal("answer_provided", value) # This emits a custom signal answer_provided, which is then handled by the game script
