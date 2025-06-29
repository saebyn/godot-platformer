extends Node2D

@onready var game_menu := $GameMenu
@onready var game_scene := $GameScene
@onready var music_player := $MusicAudioStreamPlayer

func _ready() -> void:
  GameManager.game_over.connect(_on_game_manager_game_over)


func _on_game_manager_game_over(player_won: bool) -> void:
  # Pause the game when game over occurs
  get_tree().paused = true
  # Load the game over screen
  game_menu.show()
  game_scene.hide()


func _on_game_menu_exit_game() -> void:
  # Exit the game
  get_tree().quit()


func _on_game_menu_return_main_menu() -> void:
  # Return to the main menu
  get_tree().paused = true
  game_menu.show()
  game_scene.hide()


func _on_game_menu_start_game() -> void:
  # Start the game
  get_tree().paused = false
  # Hide the game menu
  game_menu.hide()
  
  # Start the game scene
  game_scene.show()

  # start the music
  music_player.play()

  GameManager.setup_game()


func _on_game_menu_restart_game() -> void:
  print("Restarting game")
  GameManager.restart_level()
  game_menu.unpause()
