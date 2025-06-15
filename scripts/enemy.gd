extends CharacterBody2D

@export var speed: float = 100.0

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var ground_check: RayCast2D = $GroundCheck
@onready var wall_check: RayCast2D = $WallCheck

var direction: int = 1  # 1 for right, -1 for left

func _ready() -> void:
	# Ensure raycasts are enabled
	if ground_check:
		ground_check.enabled = true
	if wall_check:
		wall_check.enabled = true
	
	# Update wall check direction initially
	update_raycast_directions()

func _physics_process(delta: float) -> void:
	# Add gravity
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	# Check for edges and walls
	if should_turn_around():
		direction *= -1
		flip_sprite()
		update_raycast_directions()
	
	# Move horizontally
	velocity.x = direction * speed
	
	# Update sprite animation
	if is_on_floor():
		sprite.play("default")
	
	move_and_slide()

func should_turn_around() -> bool:
	# Turn around if there's no ground ahead or if hitting a wall
	var no_ground_ahead = ground_check and not ground_check.is_colliding()
	var hitting_wall = wall_check and wall_check.is_colliding()
	
	return no_ground_ahead or hitting_wall

func flip_sprite() -> void:
	sprite.scale.x = -direction

func update_raycast_directions() -> void:
	# Update wall check direction based on movement direction
	if wall_check:
		wall_check.target_position = Vector2(20 * direction, 0)
	
	# Update ground check position to be ahead in movement direction
	if ground_check:
		ground_check.position = Vector2(15 * direction, 25)