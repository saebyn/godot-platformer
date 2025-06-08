extends Area2D

@onready var player: Node2D = $"../Player"

func _on_body_entered(body: Node2D) -> void:
  if body is CharacterBody2D:
    var character: CharacterBody2D = body as CharacterBody2D

    character.velocity = Vector2.ZERO

    # If the character is the player, reset the game.
    if character.is_in_group("player"):
      GameManager.setup_game()
    else:
      character.queue_free()


func _process(_delta: float) -> void:
  # Update the dead zone's horizontal position to match the player's position
  position.x = player.position.x
