@tool
extends GameMenuButton
class_name NewGameButton

## New Game button that starts a new game session
## Extends the base GameMenuButton with specific functionality

func _ready() -> void:
	action_name = "NewGameButton"
	super._ready()

## Override to add new game specific behavior if needed
func _on_button_pressed() -> void:
	super._on_button_pressed()
	# Add any new game specific logic here