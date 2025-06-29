extends CharacterBody2D


@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

var current_direction_suffix: String = "s" # Default to south for idle animation

const IDLE_MAX_SPEED = 0.1
const SPEED = 300.0


func _physics_process(_delta: float) -> void:
  # Get the input direction and handle the movement/deceleration.
  # As good practice, you should replace UI actions with custom gameplay actions.
  var direction := Input.get_vector("move_left", "move_right", "move_up", "move_down")
  if direction:
    velocity = direction * SPEED
  else:
    velocity.x = move_toward(velocity.x, 0, SPEED)
    velocity.y = move_toward(velocity.y, 0, SPEED)

  # Update the direction-based sprite animation based on the direction
  # If not moving, play idle animation for that direction
  if direction.length() > IDLE_MAX_SPEED:
    current_direction_suffix = _direction_suffix_from_direction(direction)
    sprite.play("walk_" + current_direction_suffix)
  else:
    sprite.play("idle_" + current_direction_suffix)


  move_and_slide()


func _direction_suffix_from_direction(direction: Vector2) -> String:
  # what is the main direction of the player?
  if abs(direction.x) > abs(direction.y):
    return "e" if direction.x > 0 else "w"
  else:
    return "s" if direction.y > 0 else "n"