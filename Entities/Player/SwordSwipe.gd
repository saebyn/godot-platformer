extends Node2D

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision_area: Area2D = $AttackArea

signal swipe_finished()

func _ready() -> void:
  # Connect animation finished signal
  sprite.animation_finished.connect(_on_animation_finished)
  # Initially hide the swipe effect
  visible = false

func play_swipe(facing_right: bool) -> void:
  # Show and position the swipe effect
  visible = true
  
  # Flip the sprite based on facing direction
  sprite.flip_h = not facing_right
  
  # Position the swipe relative to facing direction
  var offset_x = 40 if facing_right else -40
  position.x = offset_x
  
  # Play the swipe animation
  sprite.play("swipe")

func _on_animation_finished() -> void:
  if sprite.animation == "swipe":
    visible = false
    swipe_finished.emit()


func get_hits() -> Array:
  var hits = []
  # Check for collisions in the attack area
  for body in collision_area.get_overlapping_bodies():
    if body is Node2D:
      hits.append(body)
  return hits