@tool
extends GameMenuButton
class_name LoadGameButton

## Load Game button that loads a saved game session
## Extends the base GameMenuButton with specific functionality

func _ready() -> void:
	action_name = "LoadGameButton"
	super._ready()

## Override to add load game specific behavior if needed
func _on_button_pressed() -> void:
	super._on_button_pressed()
	# Add any load game specific logic here