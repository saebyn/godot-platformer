extends CharacterBody2D

@export var jump_velocity: float = -800.0
@export var slide_velocity: float = 600.0
@export var speed: float = 300.0

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D


var started_jumping: bool = false
var started_idle: bool = false


func _physics_process(delta: float) -> void:
  # Add the gravity.
  if not is_on_floor():
    velocity += get_gravity() * delta

  # Handle jump.
  if Input.is_action_just_pressed("move_jump") and is_on_floor():
    velocity.y = jump_velocity

  # Get the input direction and handle the movement/deceleration.
  var direction := Input.get_axis("move_left", "move_right")
  if direction:
    velocity.x = direction * speed
  else:
    velocity.x = move_toward(velocity.x, 0, speed)

  # If the player is holding the slide button, apply a slide velocity.
  if Input.is_action_pressed("move_slide") and is_on_floor():
    velocity.y = slide_velocity

  # if the player is moving, flip the sprite.
  if abs(direction) > 0.1:
    sprite.scale.x = sign(direction)
  else:
    sprite.scale.x = 1

  # Update the sprite animation based on the velocity.
  if is_on_floor():
    started_jumping = false
    if abs(velocity.x) > 0.1:
      sprite.play("walk")
    else:
      sprite.play("idle")
  else:
    if not started_jumping:
      started_jumping = true
      sprite.play("jump")

  move_and_slide()
