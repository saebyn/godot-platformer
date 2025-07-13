extends CharacterBody2D

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

var level_entrance_tile_data: TileData

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


func _on_level_entrance_entered(body_rid: RID, body: Node2D, _body_shape_index: int, _local_shape_index: int) -> void:
  print("Entered level entrance from tilemaplayer: ", body.name)
  # Get the tile from the tilemaplayer
  if body is TileMapLayer:
    var tilemap_layer: TileMapLayer = body
    var coords := tilemap_layer.get_coords_for_body_rid(body_rid)
    print("Tile coordinates: ", coords)
    # Get the data for the tile
    level_entrance_tile_data = tilemap_layer.get_cell_tile_data(coords)
    if level_entrance_tile_data and level_entrance_tile_data.has_custom_data("level"):
      var level = level_entrance_tile_data.get_custom_data("level")
      GameManager.enter_level.emit(level)
    else:
      print("No tile data found for coordinates: ", coords)


func _on_world_map_tree_entered() -> void:
  print("World map tree entered")
  # Get the amount to move the player from the tile data
  if level_entrance_tile_data and level_entrance_tile_data.has_custom_data("move_to_position"):
    var move_to_position: Vector2 = level_entrance_tile_data.get_custom_data("move_to_position")
    print("Moving player to position: ", move_to_position)
    position += move_to_position
    current_direction_suffix = _direction_suffix_from_direction(move_to_position)
    sprite.play("walk_" + current_direction_suffix)
    velocity = move_to_position.normalized() * SPEED
