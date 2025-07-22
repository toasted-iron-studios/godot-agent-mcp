@tool
extends Control
class_name MainMenuController

## Main menu controller that handles all menu button interactions
## Demonstrates clean separation of concerns and signal-based architecture

func _ready() -> void:
	connect_menu_buttons()

## Connects all GameMenuButton signals to the appropriate handlers
func connect_menu_buttons() -> void:
	var buttons: Array[Node] = find_children("*Button", "Button", true, false)
	
	for button: Node in buttons:
		if button.has_signal("menu_action_triggered"):
			var menu_button: Button = button as Button
			menu_button.menu_action_triggered.connect(_on_menu_action_triggered)

## Handles all menu actions from buttons
## Parameters:
##   - action_name: The name of the action that was triggered
func _on_menu_action_triggered(action_name: String) -> void:
	match action_name:
		"NewGameButton":
			handle_new_game()
		"LoadGameButton":
			handle_load_game()
		"SettingsButton":
			handle_settings()
		"CreditsButton":
			handle_credits()
		"ExitButton":
			handle_exit()
		_:
			print("Unknown menu action: ", action_name)

## Handles new game action
func handle_new_game() -> void:
	print("Starting new game...")
	# Add your new game logic here

## Handles load game action
func handle_load_game() -> void:
	print("Loading saved game...")
	# Add your load game logic here

## Handles settings action
func handle_settings() -> void:
	print("Opening settings...")
	# Add your settings logic here

## Handles credits action
func handle_credits() -> void:
	print("Showing credits...")
	# Add your credits logic here

## Handles exit action
func handle_exit() -> void:
	print("Exiting game...")
	get_tree().quit() 