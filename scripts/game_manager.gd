@tool
extends Node
class_name GameManager

## Central game manager that handles game state and transitions
## Follows singleton pattern for global access

signal game_state_changed(new_state: String)

enum GameState {
	MAIN_MENU,
	IN_GAME,
	PAUSED,
	SETTINGS,
	CREDITS
}

var current_state: GameState = GameState.MAIN_MENU

func _ready() -> void:
	set_game_state(GameState.MAIN_MENU)

## Changes the current game state
## Parameters:
##   - new_state: The new game state to transition to
func set_game_state(new_state: GameState) -> void:
	if current_state != new_state:
		var old_state = current_state
		current_state = new_state
		game_state_changed.emit(GameState.keys()[new_state])
		handle_state_transition(old_state, new_state)

## Handles state transitions and performs necessary actions
## Parameters:
##   - old_state: The previous game state
##   - new_state: The new game state
func handle_state_transition(old_state: GameState, new_state: GameState) -> void:
	print("Game state changed from ", GameState.keys()[old_state], " to ", GameState.keys()[new_state])
	
	match new_state:
		GameState.MAIN_MENU:
			show_main_menu()
		GameState.IN_GAME:
			start_game()
		GameState.PAUSED:
			pause_game()
		GameState.SETTINGS:
			show_settings()
		GameState.CREDITS:
			show_credits()

## Shows the main menu
func show_main_menu() -> void:
	print("Showing main menu")

## Starts the game
func start_game() -> void:
	print("Starting game")

## Pauses the game
func pause_game() -> void:
	get_tree().paused = true
	print("Game paused")

## Shows the settings menu
func show_settings() -> void:
	print("Showing settings")

## Shows the credits screen
func show_credits() -> void:
	print("Showing credits")