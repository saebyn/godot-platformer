class_name NPC
extends Area2D

@export var dialog_timeline: DialogicTimeline
@export var dialog_label: String = ""

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var label: Label = $Label


func interact() -> void:
    if not dialog_timeline:
      print("No dialog timeline set for NPC: ", name)
      return

    if Dialogic.current_timeline != null:
      print("Cannot interact with NPC while another dialog is active.")
      return

    # Start the dialog timeline for this NPC
    Dialogic.start(dialog_timeline, dialog_label)


# This function can be called when the player approaches the NPC
func approach() -> void:
    print("Approaching NPC: ", name)
    # Check if the NPC has a dialog timeline set
    if not dialog_timeline:
        print("NPC has no dialog timeline set.")
        return

    # highlight the NPC by modulating its appearance
    sprite.modulate = Color(1, 1, 0.5) # Yellowish highlight

    label.text = "Press action key to interact with " + name
    label.show()


# This function can be called when the player leaves the NPC
func leave() -> void:
    print("Leaving NPC: ", name)
    # Reset the NPC's appearance
    sprite.modulate = Color(1, 1, 1) # Reset to normal color
    label.hide()
