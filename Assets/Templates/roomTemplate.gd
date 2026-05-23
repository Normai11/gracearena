@tool
@icon("res://Assets/Templates/Room.svg")
## A node used by RoomManager nodes to generate a sequence of rooms.
##
## Rooms can contain any 2D or Control nodes to be later instantiated in-game.
## These nodes rely on their respective RoomConfiguration files, which are read by RoomManagers
## to position them correctly in generation.
class_name Room
extends Node2D

@export_group("Room Configuration", "room")
@export var roomCFGFile : RoomConfiguration
@export var roomSize : Vector2
@export var roomOffset : Vector2
@export var roomContinueMarker : Marker2D
@export_tool_button("Auto-configurate RoomCFG", "ActionPaste") var configTarget = auto_configurate

var roomFlipped : bool = false

func _ready() -> void:
	if Engine.is_editor_hint():
		return
	if roomFlipped:
		scale.x = -1

func auto_configurate() -> void:
	if !roomCFGFile:
		printerr("Cfg File is missing!")
		return
	if roomSize == Vector2.ZERO:
		printerr("Size Vector cannot be ZERO!")
		return
	if roomOffset == Vector2.ZERO:
		printerr("Offset Vector cannot be ZERO!")
		return
	if roomContinueMarker.position == Vector2.ZERO:
		printerr("Continue Position Vector cannot be ZERO!")
		return
	
	roomCFGFile.roomScenePath = self.scene_file_path
	roomCFGFile.roomSize = roomSize
	roomCFGFile.roomOffset = roomOffset
	roomCFGFile.roomContinuePosition = roomContinueMarker.position
