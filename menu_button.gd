@tool
extends Button
class_name GameMenuButton

## A reusable menu button that emits signals and provides logging
## Follows Godot 4+ best practices for UI interaction

signal menu_action_triggered(action_name: String)

## The action name this button represents
@export var action_name: String = ""

## Whether to print debug information when pressed
@export var debug_logging: bool = true

func _ready() -> void:
	if action_name.is_empty():
		action_name = name
	
	pressed.connect(_on_button_pressed)

## Handles button press events and emits appropriate signals
func _on_button_pressed() -> void:
	if debug_logging:
		print("Menu button pressed: ", action_name)
	
	menu_action_triggered.emit(action_name) 