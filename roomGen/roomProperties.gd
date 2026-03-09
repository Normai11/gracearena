@tool
class_name Room
extends Node2D

@export var roomSize : Vector2
@export var roomOffset : Vector2
@export var startFlipping : bool = false
@export var roomFlipped : bool = false
@export var endGen : bool = false
@export_category("Room Configuration")
@export var roomContObj : Marker2D
@export var boundControlObject : Control
@export_tool_button("Auto-configurate", "Node") var target = auto_configurate

func _ready() -> void:
	if roomFlipped:
		scale.x = -1
	if Engine.is_editor_hint():
		return
	
	if boundControlObject:
		boundControlObject.queue_free()
	if roomContObj:
		roomContObj.queue_free()

func auto_configurate():
	if !boundControlObject:
		printerr("No Bound Control Object set!")
		return
	
	var undo_redo = EditorInterface.get_editor_undo_redo()
	undo_redo.create_action("Automatically Configured Room")
	
	var targetSize = boundControlObject.size
	undo_redo.add_do_property(self, &"roomSize", targetSize)
	undo_redo.add_do_property(self, &"roomOffset", Vector2(targetSize.x/2, -targetSize.y/2))
	undo_redo.add_undo_property(self, &"roomSize", roomSize)
	undo_redo.add_undo_property(self, &"roomOffset", roomOffset)
	undo_redo.commit_action()
	#self.position = Vector2(targetSize.x/2, -targetSize.y/2)
