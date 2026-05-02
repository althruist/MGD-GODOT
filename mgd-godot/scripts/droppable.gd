extends NinePatchRect

signal answer_provided(value: int)

func _can_drop_data(at_position: Vector2, data: Variant) -> bool:
	return data is Dictionary and data.get("type") == "answer"

func _drop_data(at_position: Vector2, data: Variant) -> void:
	var value = data["value"]
	emit_signal("answer_provided", value)
