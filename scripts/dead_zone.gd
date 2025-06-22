extends Area2D

enum DamageType {
  HIT,
  VOID
}

@export var damage_type: DamageType = DamageType.VOID


func _on_body_entered(body: Node2D) -> void:
  if body is CharacterBody2D:
    var character: CharacterBody2D = body as CharacterBody2D

    character.velocity = Vector2.ZERO

    if damage_type == DamageType.HIT:
      if character.is_in_group("player"):
        character.take_damage()
    elif damage_type == DamageType.VOID:
      if character.is_in_group("player"):
        character.die()
      else:
        character.queue_free() # Remove non-player characters from the scene