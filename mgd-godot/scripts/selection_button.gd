extends TextureButton

var isSelectable = false

var lib = preload("res://animations/NumberButton.res")

func _ready() -> void:
	if get_node(".").is_in_group("Selectable"):
		isSelectable = true

func _notification(what):
	if what == NOTIFICATION_DRAG_END:
		visible = true

func _get_drag_data(at_position: Vector2) -> Variant: # Gets the data from the dragged object
	if not isSelectable: return # Checks if the item being dragged is part of the Selectable group
	visible = false # Makes the dragged item invisible (the box)
	Input.vibrate_handheld(40, 0.5) # Vibrates phone (i'm extra as hell lol)
	var prev = TextureButton.new() # Creates a preview box that follows your finger
	var animation = AnimationPlayer.new() # Creates an animation... (cuz i'm extra)
	animation.add_animation_library("NumberButton",lib) # Adds animation library since I organized it
	prev.texture_normal = texture_normal #            -------
	prev.scale = Vector2(2, 2) #                            |
	prev.pivot_offset_ratio = Vector2(0.5, 0.5) #           |
	prev.self_modulate = self_modulate #                    | These set the properties
	prev.set_anchors_preset(PRESET_CENTER) #                | to the preview box
	prev.add_child(animation) #                             |
	animation.play("NumberButton/Hold") #                   |
	set_drag_preview(prev) #                          ------- This line is a default function that Godot offers to follow your finger/mouse while dragging

	return { # This is the data that is sent to the drop area, which sends the type of data (sending an answer), the value (number), and the node itself for animations
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
