extends CharacterBody2D

@export var speed: float = 100.0
@export var wall_check_distance: float = 25.0
@export var ground_check_right_offset: float = 35.0
@export var ground_check_left_offset: float = 40.0
@export var ground_check_vertical_offset: float = 25.0

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var ground_check: RayCast2D = $GroundCheck
@onready var wall_check: RayCast2D = $WallCheck

var direction: int = 1 # 1 for right, -1 for left
var direction_change_cooldown: float = 0.0
var cooldown_time: float = 0.3 # Prevent direction changes for 0.3 seconds
var initial_position: Vector2 # Store starting position for respawn

func _ready() -> void:
  # Store initial position for reset
  initial_position = global_position
  
  # Connect to game reset signal
  GameManager.game_reset.connect(_on_game_reset)
  
  # Update wall check direction initially
  update_raycast_directions()

func _physics_process(delta: float) -> void:
  # Add gravity
  if not is_on_floor():
    velocity += get_gravity() * delta
  
  # Update cooldown timer
  if direction_change_cooldown > 0:
    direction_change_cooldown -= delta
  
  # Check for edges and walls (only if cooldown has expired)
  if direction_change_cooldown <= 0 and should_turn_around():
    direction *= -1
    flip_sprite()
    update_raycast_directions()
    direction_change_cooldown = cooldown_time # Start cooldown
  
  # Move horizontally
  velocity.x = direction * speed
  
  move_and_slide()

func should_turn_around() -> bool:
  # Turn around if there's no ground ahead or if hitting a wall
  var no_ground_ahead = not ground_check.is_colliding()
  var hitting_wall = wall_check.is_colliding()
  
  return no_ground_ahead or hitting_wall

func flip_sprite() -> void:
  sprite.flip_h = direction > 0

func update_raycast_directions() -> void:
  # Update wall check direction based on movement direction
  wall_check.target_position = Vector2(wall_check_distance * direction, 0)
  
  # Update ground check position to be at the edge of the collision shape
  # Collision shape is rotated 90 degrees, so it's 50 pixels wide (height becomes width)
  # Positioned at (-5, 0), so right edge is at 20 pixels, left edge at -30 pixels from center
  # Position the raycast beyond the collision edge for proper detection
  if direction > 0: # Moving right
    ground_check.position = Vector2(ground_check_right_offset, ground_check_vertical_offset)
  else: # Moving left
    ground_check.position = Vector2(-ground_check_left_offset, ground_check_vertical_offset)


func _on_game_reset() -> void:
  # Reset enemy to initial state
  global_position = initial_position
  velocity = Vector2.ZERO
  direction = 1 # Reset to moving right
  direction_change_cooldown = 0.0
  flip_sprite()
  update_raycast_directions()