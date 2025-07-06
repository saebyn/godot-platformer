extends Node2D

@onready var game_menu := $GameMenu
@onready var music_player := $MusicAudioStreamPlayer

@export var world_map: PackedScene
var world_map_instance: Node2D = null
var level_instance: Node2D = null

func _ready() -> void:
  GameManager.game_over.connect(_on_game_manager_game_over)
  GameManager.enter_level.connect(_on_game_manager_enter_level)


func _on_game_manager_game_over(_player_won: bool) -> void:
  # Pause the game when game over occurs
  get_tree().paused = true
  # TODO Load the game over screen
  game_menu.show()

func _on_game_manager_enter_level(level: PackedScene) -> void:
  # Instantiate the level and add it to the scene tree
  level_instance = level.instantiate()
  get_tree().current_scene.add_child(level_instance)
  # remove the world map from the scene tree
  world_map_instance.queue_free()
  world_map_instance = null


func _on_game_menu_exit_game() -> void:
  # Exit the game
  get_tree().quit()


func _on_game_menu_return_main_menu() -> void:
  # Return to the main menu
  get_tree().paused = true

  # Remove the current level instance if it exists
  if level_instance:
    level_instance.queue_free()
    level_instance = null

  game_menu.show()


func _on_game_menu_start_game() -> void:
  # Start the game
  get_tree().paused = false
  # Hide the game menu
  game_menu.hide()
  
  # start the music
  music_player.play()

  # add the world map to the scene tree
  world_map_instance = world_map.instantiate()
  get_tree().current_scene.add_child(world_map_instance)

  GameManager.setup_game()


func _on_game_menu_restart_game() -> void:
  print("Restarting game")
  GameManager.restart_level()
  game_menu.unpause()
