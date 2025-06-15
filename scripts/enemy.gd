extends CharacterBody2D

@export var speed: float = 100.0

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var ground_check: RayCast2D = $GroundCheck
@onready var wall_check: RayCast2D = $WallCheck

var direction: int = 1 # 1 for right, -1 for left
var direction_change_cooldown: float = 0.0
var cooldown_time: float = 0.3  # Prevent direction changes for 0.3 seconds

func _ready() -> void:
  # Set collision mask for raycasts to detect terrain (layer 1)
  if ground_check:
    ground_check.enabled = true
    ground_check.collision_mask = 1
  if wall_check:
    wall_check.enabled = true
    wall_check.collision_mask = 1
  
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
    direction_change_cooldown = cooldown_time  # Start cooldown
  
  # Move horizontally
  velocity.x = direction * speed
  
  move_and_slide()

func should_turn_around() -> bool:
  # Turn around if there's no ground ahead or if hitting a wall
  var no_ground_ahead = ground_check and not ground_check.is_colliding()
  var hitting_wall = wall_check and wall_check.is_colliding()
  
  return no_ground_ahead or hitting_wall

func flip_sprite() -> void:
  sprite.scale.x = - direction

func update_raycast_directions() -> void:
  # Update wall check direction based on movement direction
  if wall_check:
    wall_check.target_position = Vector2(25 * direction, 0)
  
  # Update ground check position to be at the edge of the collision shape
  # Collision shape is rotated 90 degrees, so it's 50 pixels wide (height becomes width)
  # Positioned at (-5, 0), so right edge is at 20 pixels, left edge at -30 pixels from center
  # Position the raycast beyond the collision edge for proper detection
  if ground_check:
    if direction > 0:  # Moving right
      ground_check.position = Vector2(35, 25)  # Position well beyond right edge
    else:  # Moving left  
      ground_check.position = Vector2(-40, 25)  # Position well beyond left edge