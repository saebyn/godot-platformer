extends Node

const SAVE_FILE_PATH = "user://savegame.json"

signal game_over(player_won: bool)
signal game_reset()

signal player_gets_sword()
signal player_load(player_data: Dictionary)

signal enter_level(level: PackedScene)


func setup_game() -> void:
  game_reset.emit()


func restart_level() -> void:
  game_reset.emit()


func give_player_sword() -> void:
  player_gets_sword.emit()


func _get_player() -> Node:
  # Get the player node from the scene tree
  return get_tree().get_nodes_in_group("player")[0] if get_tree().get_nodes_in_group("player") else null


func save_game() -> void:
  Dialogic.Save.save()

  var save_file = FileAccess.open(SAVE_FILE_PATH, FileAccess.WRITE)

  var player_node = _get_player()

  if player_node:
    var data = player_node.serialize()
    save_file.store_line(JSON.stringify(data))

  save_file.close()


func load_game() -> void:
  print("Loading game from: ", SAVE_FILE_PATH)
  var save_file = FileAccess.open(SAVE_FILE_PATH, FileAccess.READ)
  var json = JSON.new()
  if save_file:
    var data = save_file.get_as_text()
    var parse_result = json.parse(data)

    if not parse_result == OK:
      print("JSON Parse Error: ", json.get_error_message(), " in ", data, " at line ", json.get_error_line())
      return

    # Get the data from the JSON object.
    player_load.emit(json.data)

  if Dialogic.Save.has_slot(""):
    print("Loading Dialogic Save")
    Dialogic.Save.load()
  else:
    print("No Dialogic Save found, skipping load.")
