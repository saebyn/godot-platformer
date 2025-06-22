extends Node

var scores_path: String = "user://high_scores.cfg"

signal game_over(player_won: bool)
signal game_reset()

class Score extends Resource:
  var score: int
  var initials: String

  func _init(score_: int, initials_: String) -> void:
    self.score = score_
    self.initials = initials_

@export var high_scores: Array[Score] = []


func setup_game() -> void:
  game_reset.emit()


func restart_level() -> void:
  game_reset.emit()


func give_player_sword() -> void:
  # This function can be used to give the player a sword or other power-ups
  # Implementation depends on the game logic, e.g., adding a sword node to the player
  pass