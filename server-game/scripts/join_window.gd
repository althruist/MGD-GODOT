extends Control

@export var mainWindow: Control;

func _on_join_pressed() -> void:
	mainWindow.visible = false
	visible = true
