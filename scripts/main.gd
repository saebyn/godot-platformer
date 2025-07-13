extends Node2D

@onready var game_menu := $GameMenu
@onready var music_player := $MusicAudioStreamPlayer

@export var world_map: PackedScene
@export var level_container_scene: PackedScene
var world_map_instance: Node2D = null
var level_container: LevelContainer = null


func _ready() -> void:
  level_container = level_container_scene.instantiate()
  level_container.parent = self
  world_map_instance = world_map.instantiate()
  GameManager.game_over.connect(_on_game_manager_game_over)
  GameManager.enter_level.connect(_on_game_manager_enter_level)


func _on_game_manager_game_over(_player_won: bool) -> void:
  # For now, just trigger a save here
  GameManager.save_game()

  # Send the player back to the world map
  level_container.unload()

  add_child(world_map_instance)


func _on_game_manager_enter_level(level: PackedScene) -> void:
  level_container.load(level)
  # remove the world map from the scene tree
  remove_child(world_map_instance)
  
  GameManager.setup_game()


func _on_game_menu_exit_game() -> void:
  # Exit the game
  get_tree().quit()


func _on_game_menu_return_main_menu() -> void:
  # Return to the main menu
  get_tree().paused = true

  # Remove the world map instance from the scene tree
  if world_map_instance:
    remove_child(world_map_instance)

  # Remove the current level instance if it exists
  level_container.unload()

  game_menu.show()


func _on_game_menu_start_game() -> void:
  # Start the game
  get_tree().paused = false
  # Hide the game menu
  game_menu.hide()
  
  # start the music
  music_player.play()

  # add the world map to the scene tree
  add_child(world_map_instance)

  GameManager.load_game()


func _on_game_menu_restart_game() -> void:
  print("Restarting game")
  GameManager.restart_level()
  game_menu.unpause()
