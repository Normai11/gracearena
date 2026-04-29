@tool
class_name Interactable
extends Node2D

@export var promptName : String = ""
@export var overhaulCamera : bool = false:
	set(overhaul):
		overhaulCamera = overhaul
		notify_property_list_changed()
var camFocusMode = 0
var camFocusDrag : float = 0.15
var camFocusZoom : Vector2 = Vector2(0.7, 0.7)
var revertCamera : bool = false

func _get_property_list() -> Array[Dictionary]:
	var properties : Array[Dictionary] = []
	
	if overhaulCamera:
		properties.append({
			"name" : "camFocusMode",
			"type" : TYPE_INT,
			"usage" : PROPERTY_USAGE_DEFAULT
		})
		properties.append({
			"name" : "camFocusDrag",
			"type" : TYPE_FLOAT,
			"usage" : PROPERTY_USAGE_DEFAULT
		})
		properties.append({
			"name" : "camFocusZoom",
			"type" : TYPE_VECTOR2,
			"hint" : PROPERTY_HINT_LINK,
			"usage" : PROPERTY_USAGE_DEFAULT
		})
		properties.append({
			"name" : "revertCamera",
			"type" : TYPE_BOOL,
			"usage" : PROPERTY_USAGE_DEFAULT
		})
	
	return properties

func _interacted() -> void:
	print("Object " + str(promptName) + " interacted")
	if overhaulCamera:
		var camera : AdvancedCamera = get_tree().current_scene.find_child("advCamera")
		if !revertCamera:
			camera.set_new_camera(self, camFocusMode, camFocusDrag, camFocusZoom)
		else:
			var old = camera.oldProperties
			camera.set_new_camera(old[0], old[1], old[2], old[3])
