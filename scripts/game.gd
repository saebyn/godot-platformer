extends Node2D

@onready var player: CharacterBody2D = $Player
@onready var camera: Camera2D = $Camera2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
  GameManager.game_reset.connect(_on_game_reset)


func _on_game_reset() -> void:
  # Enable the camera
  camera.enabled = true
  # Reset the player position and velocity.
  player.position = Vector2(698, 457)
  player.velocity = Vector2.ZERO

func _on_hide() -> void:
  # Disable the camera when the scene is hidden
  camera.enabled = false