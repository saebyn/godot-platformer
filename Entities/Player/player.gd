extends CharacterBody2D

@export_group("Movement")
@export var jump_velocity: float = -800.0
@export var slide_velocity: float = 600.0
@export var speed: float = 300.0

@export_group("Invulnerability")
@export var invulnerability_duration: float = 1.5 # Seconds of invulnerability after hit
@export var flash_frequency: float = 0.1 # How fast to flash during invulnerability

@export_group("Power State Visuals")
@export var small_scale: float = 0.75
@export var normal_scale: float = 1.0
@export var powered_scale: float = 1.25

@export_group("Inventory")
@export var has_sword: bool = false # Whether the player has a sword

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var target_detector: RayCast2D = $TargetDetector

var npc: NPC = null # Reference to the adjacent NPC for interaction

# Power-up state system
enum PowerState {
  SMALL = 0, # Takes one hit to die
  NORMAL = 1, # Default state, takes one hit to become small
  POWERED = 2 # Takes one hit to become normal
}

var power_state: PowerState = PowerState.NORMAL
var started_jumping: bool = false
var started_idle: bool = false

# Invulnerability system
var is_invulnerable: bool = false
var invulnerability_timer: float = 0.0

# Signals for power state changes
signal power_state_changed(new_state: PowerState)
signal player_died()


func _physics_process(delta: float) -> void:
  # Handle invulnerability timer
  if is_invulnerable:
    invulnerability_timer -= delta
    if invulnerability_timer <= 0:
      is_invulnerable = false
      sprite.modulate.a = 1.0 # Ensure sprite is fully visible
      _update_power_visuals() # Restore proper color
    else:
      # Flash effect during invulnerability
      var flash_time = fmod(invulnerability_timer, flash_frequency * 2)
      sprite.modulate.a = 0.3 if flash_time < flash_frequency else 1.0
  
  # Add the gravity.
  if not is_on_floor():
    velocity += get_gravity() * delta

  # Handle jump.
  if Input.is_action_just_pressed("move_jump") and is_on_floor():
    velocity.y = jump_velocity

  # Get the input direction and handle the movement/deceleration.
  var move_direction := Input.get_axis("move_left", "move_right")
  if move_direction:
    sprite.flip_h = move_direction < 0 # Flip sprite based on direction
    target_detector.target_position = Vector2(sign(move_direction) * 100, 0) # Update NPC detector direction
    velocity.x = move_direction * speed
  else:
    velocity.x = move_toward(velocity.x, 0, speed)

  # If the player is holding the slide button, apply a slide velocity.
  if Input.is_action_pressed("move_slide") and is_on_floor():
    velocity.y = slide_velocity

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

  # NPC interaction
  if target_detector.is_colliding():
    var collider: Node2D = target_detector.get_collider()
    if collider is NPC:
      if collider != npc:
        if npc:
          npc.leave() # Leave previous NPC
        npc = collider
        npc.approach() # Approach new NPC
  else:
    if npc:
      npc.leave() # Leave NPC if no longer colliding
      npc = null

  move_and_slide()


# Power-up state management methods
func take_damage() -> void:
  # Don't take damage if invulnerable
  if is_invulnerable:
    return
    
  # Handle taking damage - either decrease power state or die
  match power_state:
    PowerState.POWERED:
      set_power_state(PowerState.NORMAL)
      _start_invulnerability()
    PowerState.NORMAL:
      set_power_state(PowerState.SMALL)
      _start_invulnerability()
    PowerState.SMALL:
      die()


func _start_invulnerability() -> void:
  # Start invulnerability period with flashing effect
  is_invulnerable = true
  invulnerability_timer = invulnerability_duration


func set_power_state(new_state: PowerState) -> void:
  # Set the player's power state and update visuals
  if power_state != new_state:
    power_state = new_state
    power_state_changed.emit(new_state)
    _update_power_visuals()


func power_up() -> void:
  # Increase power state (for power-up items)
  match power_state:
    PowerState.SMALL:
      set_power_state(PowerState.NORMAL)
    PowerState.NORMAL:
      set_power_state(PowerState.POWERED)
    PowerState.POWERED:
      # Already at max power, maybe add score or other effect
      pass


func die() -> void:
  # Handle player death
  player_died.emit()
  GameManager.setup_game()
  Dialogic.end_timeline()


func _update_power_visuals() -> void:
  # Update sprite scale/color based on power state
  var direction_sign = sign(sprite.scale.x) if sprite.scale.x != 0 else 1
  
  match power_state:
    PowerState.SMALL:
      sprite.modulate = Color.LIGHT_GRAY
      sprite.scale = Vector2(small_scale * direction_sign, small_scale)
      collision_shape.scale = Vector2(small_scale, small_scale)
    PowerState.NORMAL:
      sprite.modulate = Color.WHITE
      sprite.scale = Vector2(normal_scale * direction_sign, normal_scale)
      collision_shape.scale = Vector2(normal_scale, normal_scale)
    PowerState.POWERED:
      sprite.modulate = Color.LIGHT_BLUE
      sprite.scale = Vector2(powered_scale * direction_sign, powered_scale)
      collision_shape.scale = Vector2(powered_scale, powered_scale)


func _ready() -> void:
  # Initialize the player
  _update_power_visuals()

  GameManager.player_gets_sword.connect(get_sword)


func reset_player() -> void:
  # Reset player to default state
  set_power_state(PowerState.NORMAL)
  velocity = Vector2.ZERO
  # Clear invulnerability state on reset
  is_invulnerable = false
  invulnerability_timer = 0.0
  sprite.modulate.a = 1.0


func _input(event: InputEvent) -> void:
  if event is InputEventKey and event.is_action_pressed("game_interact"):
    if npc:
      npc.interact()
    elif has_sword:
      # TODO show sword attack animation
      # TODO figure out how to hit low enemies, as the raycast is only horizontal
      if target_detector.is_colliding():
        # if the target detector is colliding with anything else, hit it
        var collider: Node2D = target_detector.get_collider()
        if collider.has_method("take_damage"):
          collider.take_damage()
        elif collider.has_method("die"):
          collider.die()


func get_sword() -> void:
  # Give the player a sword
  has_sword = true