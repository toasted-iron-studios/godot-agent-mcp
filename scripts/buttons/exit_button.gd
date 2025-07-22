@tool
extends GameMenuButton
class_name ExitButton

## Exit button that closes the application
## Extends the base GameMenuButton with specific functionality

func _ready() -> void:
	action_name = "ExitButton"
	super._ready()

## Override to add exit specific behavior if needed
func _on_button_pressed() -> void:
	super._on_button_pressed()
	# Add any exit specific logic here