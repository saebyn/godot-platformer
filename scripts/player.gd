extends CharacterBody2D

@export var jump_velocity: float = -800.0
@export var slide_velocity: float = 600.0
@export var speed: float = 300.0

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

# Power-up state system
enum PowerState {
  SMALL = 0,      # Takes one hit to die
  NORMAL = 1,     # Default state, takes one hit to become small
  POWERED = 2     # Takes one hit to become normal
}

var power_state: PowerState = PowerState.NORMAL
var started_jumping: bool = false
var started_idle: bool = false

# Signals for power state changes
signal power_state_changed(new_state: PowerState)
signal player_died()


var debug_h_pressed: bool = false
var debug_p_pressed: bool = false

func _physics_process(delta: float) -> void:
  # Add the gravity.
  if not is_on_floor():
    velocity += get_gravity() * delta

  # Handle jump.
  if Input.is_action_just_pressed("move_jump") and is_on_floor():
    velocity.y = jump_velocity

  # Debug: Test power-up system with keyboard keys (for testing)
  var h_currently_pressed = Input.is_physical_key_pressed(KEY_H)
  var p_currently_pressed = Input.is_physical_key_pressed(KEY_P)
  
  if h_currently_pressed and not debug_h_pressed:  # H key just pressed - take damage (hit)
    print("DEBUG: Taking damage, current state: ", PowerState.keys()[power_state])
    take_damage()
  if p_currently_pressed and not debug_p_pressed:  # P key just pressed - power up
    print("DEBUG: Powering up, current state: ", PowerState.keys()[power_state])
    power_up()
    
  debug_h_pressed = h_currently_pressed
  debug_p_pressed = p_currently_pressed

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
    var current_scale = sprite.scale
    sprite.scale.x = abs(current_scale.x) * sign(direction)
  else:
    var current_scale = sprite.scale
    sprite.scale.x = abs(current_scale.x)

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


# Power-up state management methods
func take_damage() -> void:
  """Handle taking damage - either decrease power state or die"""
  match power_state:
    PowerState.POWERED:
      set_power_state(PowerState.NORMAL)
    PowerState.NORMAL:
      set_power_state(PowerState.SMALL)
    PowerState.SMALL:
      die()


func set_power_state(new_state: PowerState) -> void:
  """Set the player's power state and update visuals"""
  if power_state != new_state:
    power_state = new_state
    power_state_changed.emit(new_state)
    _update_power_visuals()


func power_up() -> void:
  """Increase power state (for power-up items)"""
  match power_state:
    PowerState.SMALL:
      set_power_state(PowerState.NORMAL)
    PowerState.NORMAL:
      set_power_state(PowerState.POWERED)
    PowerState.POWERED:
      # Already at max power, maybe add score or other effect
      pass


func die() -> void:
  """Handle player death"""
  player_died.emit()
  GameManager.setup_game()


func _update_power_visuals() -> void:
  """Update sprite scale/color based on power state"""
  var direction_sign = sign(sprite.scale.x) if sprite.scale.x != 0 else 1
  
  match power_state:
    PowerState.SMALL:
      sprite.modulate = Color.LIGHT_GRAY
      sprite.scale = Vector2(0.75 * direction_sign, 0.75)
    PowerState.NORMAL:
      sprite.modulate = Color.WHITE
      sprite.scale = Vector2(1.0 * direction_sign, 1.0) 
    PowerState.POWERED:
      sprite.modulate = Color.LIGHT_BLUE
      sprite.scale = Vector2(1.25 * direction_sign, 1.25)


func _ready() -> void:
  """Initialize the player"""
  _update_power_visuals()
  # Add player to the "player" group for identification
  add_to_group("player")


func reset_player() -> void:
  """Reset player to default state"""
  set_power_state(PowerState.NORMAL)
  velocity = Vector2.ZERO
