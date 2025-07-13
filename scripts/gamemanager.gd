extends Node

signal game_over(player_won: bool)
signal game_reset()

signal player_gets_sword()

signal enter_level(level: PackedScene)


func setup_game() -> void:
  game_reset.emit(Vector2(698, 457))


func restart_level() -> void:
  game_reset.emit(Vector2(698, 457))


func give_player_sword() -> void:
  player_gets_sword.emit()