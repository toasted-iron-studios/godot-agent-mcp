@tool
extends GameMenuButton
class_name CreditsButton

## Credits button that displays game credits
## Extends the base GameMenuButton with specific functionality

func _ready() -> void:
	action_name = "CreditsButton"
	super._ready()

## Override to add credits specific behavior if needed
func _on_button_pressed() -> void:
	super._on_button_pressed()
	# Add any credits specific logic here