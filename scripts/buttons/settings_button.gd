@tool
extends GameMenuButton
class_name SettingsButton

## Settings button that opens the settings menu
## Extends the base GameMenuButton with specific functionality

func _ready() -> void:
	action_name = "SettingsButton"
	super._ready()

## Override to add settings specific behavior if needed
func _on_button_pressed() -> void:
	super._on_button_pressed()
	# Add any settings specific logic here