extends Node2D
class_name LevelContainer

var level: Node2D = null
var parent: Node2D = null

func load(level_scene: PackedScene) -> void:
  assert(level_scene != null, "Level scene must not be null")
  assert(parent != null, "Parent must be set before loading a level")

  # Clear current level if it exists
  if level:
      level.queue_free()
  
  # Instantiate and add the new level scene
  level = level_scene.instantiate()
  add_child(level)

  # Add this LevelContainer to the scene tree
  parent.add_child(self)

func unload() -> void:
  # Remove the current level from the level container
  if level:
      level.queue_free()
      level = null

  # Remove this LevelContainer from the scene tree without freeing it
  parent.remove_child(self)
