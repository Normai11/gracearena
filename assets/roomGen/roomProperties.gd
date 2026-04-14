@tool
class_name Room
extends Node2D

@export var roomFlipped : bool = false
@export var roomConfig : roomConfiguration
#@export var roomSize : Vector2
#@export var roomOffset : Vector2
#@export var startFlipping : bool = false
#@export var endGen : bool = false
@export_category("Room Configuration")
@export var killMarkers : bool = true
@export var roomContObj : Marker2D
@export var cameraHoldObject : Marker2D
#@export_tool_button("Auto-configurate", "Node") var target = auto_configurate

var enemyChildren : Array[Enemy]

func _ready() -> void:
	if roomFlipped:
		scale.x = -1
	if Engine.is_editor_hint():
		return
	
	#if boundControlObject:
		#boundControlObject.queue_free()
	if roomContObj && killMarkers:
		roomContObj.queue_free()
	
	#for spawner in get_children():
		#if spawner is EnemySpawner:
			#spawner.enemySpawned.connect(add_enemy_to_array)
	
	#if roomConfig.roomType == roomConfig.Types.SAFEROOM && cameraHoldObject:
		#var camera : AdvancedCamera = get_tree().current_scene.find_child("advCamera")
		#camera.change_targets(cameraHoldObject, 1, 0.15, Vector2(1.24, 1.24))

func add_enemy_to_array(child : Enemy) -> void:
	enemyChildren.append(child)

func kill_enemies() -> void:
	for enemy in enemyChildren:
		if enemy:
			enemy.queue_free()
		enemyChildren.clear()

#func auto_configurate():
	#if !boundControlObject:
		#printerr("No Bound Control Object set!")
		#return
	#
	#var undo_redo = EditorInterface.get_editor_undo_redo()
	#undo_redo.create_action("Automatically Configured Room")
	#
	#var targetSize = boundControlObject.size
	#undo_redo.add_do_property(self, &"roomSize", targetSize)
	#undo_redo.add_do_property(self, &"roomOffset", Vector2(targetSize.x/2, -targetSize.y/2))
	#undo_redo.add_undo_property(self, &"roomSize", roomSize)
	#undo_redo.add_undo_property(self, &"roomOffset", roomOffset)
	#undo_redo.commit_action()
	#self.position = Vector2(targetSize.x/2, -targetSize.y/2)
