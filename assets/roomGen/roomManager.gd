@tool
class_name RoomManager
extends Node2D

@onready var doorRef = preload("res://assets/objects/door.tscn")

enum biomes {
	biomeTest = -1,
}

@export var cfgPath : String = "res://assets/roomGen/rooms/roomCFGs/"
@export var roomOffset = Vector2.ZERO
@export_group("Floor Configuration", "floor")
@export var floorBiome : biomes = biomes.biomeTest
@export var floorRoomCap : int = 15
@export var floorLimitTurns : bool = true:
	set(value):
		floorLimitTurns = value
		notify_property_list_changed()
var floorTurnReq : int = 2
var curTurnReq : int = -1
var canTurn : bool = false

var cfgFiles : Array[roomConfiguration]
var cfgChances : PackedFloat32Array
var drawQueue : Array = []
var direction : int = 1 ## 1 is RIGHT, -1 is LEFT
var roomRects : Array = []
var roomChildren : Array = []
var oldOffset : Vector2

func _ready() -> void:
	if Engine.is_editor_hint():
		return
	cfgFiles = get_config_files(floorBiome)
	for room in cfgFiles:
		cfgChances.append(room.appearChance)
	#generate_rooms()

func _get_property_list() -> Array[Dictionary]:
	var properties : Array[Dictionary] = []
	
	if floorLimitTurns:
		properties.append({
			"name" : "floorTurnReq",
			"type" : TYPE_INT,
			"usage" : PROPERTY_USAGE_DEFAULT
		})
	
	return properties

func get_config_files(biome : biomes) -> Array[roomConfiguration]:
	var output : Array[roomConfiguration] = []
	var searchString : String = DataStore.biomePaths[biome]
	
	var searchPath = DirAccess.open(cfgPath)
	var fileGet = searchPath.get_files()
	
	for file in fileGet:
		if file.begins_with(searchString):
			output.append(load(cfgPath + file))
	
	return output

func determine_position(curOffset : Vector2, roomCFG : roomConfiguration) -> Vector2:
	var curPosition = curOffset
	#var roomSize = roomCFG.get_bounds()
	var newOffset = roomCFG.get_offset()
	
	if direction == 1:
		curPosition += Vector2(newOffset.x, newOffset.y)
	else:
		curPosition += Vector2(-newOffset.x, newOffset.y)
	
	return curPosition

func generate_rooms() -> void:
	for room in range(floorRoomCap):
		curTurnReq += 1
		if curTurnReq >= floorTurnReq:
			canTurn = true
		
		var instRoom
		var pickRNG = RandomNumberGenerator.new()
		var child : roomConfiguration #= cfgFiles[pickRNG.rand_weighted(cfgChances)]
		var OK : bool = false
		while !OK:
			child = cfgFiles[pickRNG.rand_weighted(cfgChances)]
			if (child.flipDirection && !canTurn) or child.roomType != roomConfiguration.Types.TIMED:
				continue
			else:
				OK = true
		var result = check_collision(child)
		
		var idx = -1
		while result:
			print(result)
			drawQueue.append(Rect2(determine_position(roomOffset, child), child.roomBounds))
			idx += 1
			if idx >= cfgFiles.size():
				printerr("No rooms passed collision check.")
				break
			
			child = cfgFiles[idx]
			if child.roomType == roomConfiguration.Types.EXIT:
				continue
			result = check_collision(child)
		if !result:
			var temp = load(child.roomScenePath)
			var doorLoad = doorRef.instantiate()
			instRoom = temp.instantiate()
			instRoom.position = determine_position(roomOffset, child)
			instRoom.roomFlipped = (true if direction == -1 else false)
			add_child(instRoom)
			doorLoad.position = Vector2(instRoom.roomContObj.position.x, instRoom.roomContObj.position.y - 61)
			instRoom.add_child(doorLoad)
			roomChildren.append(instRoom)
			roomOffset = instRoom.roomContObj.global_position
			if child.flipDirection:
				canTurn = false
				curTurnReq = -1
				direction = -direction
			
			var addRect = Rect2(instRoom.position - (child.roomBounds/2), child.roomBounds)
			roomRects.append(addRect)
	var exitCFG : roomConfiguration
	var exit
	for room in cfgFiles:
		if room.roomType == roomConfiguration.Types.EXIT:
			exitCFG = room
	var loader = load(exitCFG.roomScenePath)
	exit = loader.instantiate()
	exit.position = determine_position(roomOffset, exitCFG)
	exit.roomFlipped = (true if direction == -1 else false)
	add_child(exit)

func check_collision(cfg : roomConfiguration) -> bool:
	var result : bool = false
	var size = cfg.get_bounds() - Vector2(5, 5)
	var roomPos = determine_position(roomOffset, cfg)
	var checkShape : Rect2 = Rect2(roomPos - size/2, size)
	
	drawQueue.append(checkShape)
	
	for collisions in roomRects:
		if checkShape.intersects(collisions):
			result = true
			break
	#if !result:
		#checkShape.position.x += (200 * direction)
		#for collisions in roomRects:
			#if checkShape.intersects(collisions):
				#result = true
				#break
	
	return result

func kill_existing_rooms() -> void:
	roomRects.clear()
	for room in roomChildren:
		room.kill_enemies()
		room.free()
	roomChildren.clear()

func _draw() -> void:
	#if !roomRects.is_empty():
		#for rect in roomRects:
			#draw_rect(rect, Color.BLUE)
	#if !drawQueue.is_empty():
		#for rect in drawQueue:
			#draw_rect(rect, Color.RED)
		#drawQueue.clear()
	pass
