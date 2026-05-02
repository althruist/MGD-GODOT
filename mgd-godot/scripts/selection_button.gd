extends TextureButton

var isSelectable = false

var lib = preload("res://animations/NumberButton.res")

func _ready() -> void:
	if get_node(".").is_in_group("Selectable"):
		isSelectable = true

func _notification(what):
	if what == NOTIFICATION_DRAG_END:
		visible = true

func _get_drag_data(at_position: Vector2) -> Variant:
	if not isSelectable: return
	visible = false
	Input.vibrate_handheld(40, 0.5)
	var prev = TextureButton.new()
	var animation = AnimationPlayer.new()
	animation.add_animation_library("NumberButton",lib)
	prev.texture_normal = texture_normal
	prev.scale = Vector2(2, 2)
	prev.pivot_offset_ratio = Vector2(0.5, 0.5)
	prev.self_modulate = self_modulate
	prev.set_anchors_preset(PRESET_CENTER)
	prev.add_child(animation)
	animation.play("NumberButton/Hold")
	set_drag_preview(prev)

	return {
		"type": "answer",
		"value": int($Label.text),
		"node": self
	}

func _on_button_down() -> void:
	if not isSelectable: return
	$AnimationPlayer.play("NumberButton/Press")


func _on_button_up() -> void:
	if not isSelectable: return
	$AnimationPlayer.play_backwards("NumberButton/Press")
	await get_tree().create_timer(0.1).timeout
	$AnimationPlayer.play("NumberButton/Idle")
