extends Node

var scores_path: String = "user://high_scores.cfg"

signal game_over(player_won: bool)
signal game_reset()

signal player_gets_sword()

signal enter_level(level: PackedScene)


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
  player_gets_sword.emit()