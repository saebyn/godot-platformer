extends Node2D

@onready var player: CharacterBody2D = $Player
@onready var camera: Camera2D = $Camera2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
  GameManager.game_reset.connect(_on_game_reset)


func _on_game_reset() -> void:
  # Reset the player position and velocity.
  player.position = Vector2(698, 457)
  player.velocity = Vector2.ZERO
  # Reset player power state
  if player.has_method("reset_player"):
    player.reset_player()
