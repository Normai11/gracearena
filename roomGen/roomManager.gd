@tool
extends Node2D

enum biomes {
	biomeTest
}

## May tamper with export variables. Use with caution!
@export_tool_button("Test Generation (IN-EDITOR)", "Warning") var target = editor_gen_test
@export_tool_button("Reset Tamper-probable Values", "CodeEdit") var targetClear = editor_gen_cleanse

@export var cfgPath : String = "res://roomGen/rooms/roomCFGs/"
@export var roomOffset = Vector2.ZERO
@export_group("Floor Configuration", "floor")
@export var floorBiome : biomes = biomes.biomeTest
@export var floorRoomCap : int = 15
@export var floorTurnReq : int = 7
var curTurnReq : int = -1
var canTurn : bool = false
@export var floorForceTurns : bool = true
@export var floorTurnForce : int = 12

var cfgFiles : Array[roomConfiguration]
var drawQueue : Array = []
var direction : int = 1 ## 1 is RIGHT, -1 is LEFT
var roomRects : Array = []
var roomChildren : Array = []
var oldOffset : Vector2

func editor_gen_test() -> void:
	#print("haha i do nothing right now")
	generate_rooms()

func editor_gen_cleanse() -> void:
	roomOffset = Vector2.ZERO
	direction = 1
	roomRects.clear()
	curTurnReq = -1
	canTurn = false

func _ready() -> void:
	if Engine.is_editor_hint():
		return
	cfgFiles = get_config_files()
	generate_rooms()

func get_config_files() -> Array[roomConfiguration]:
	var output : Array[roomConfiguration] = []
	
	var searchPath = DirAccess.open(cfgPath)
	var fileGet = searchPath.get_files()
	
	for file in fileGet:
		output.append(load(cfgPath + file))
	
	return output

func determine_position(curOffset : Vector2, roomCFG : roomConfiguration) -> Vector2:
	var curPosition = curOffset
	var roomSize = roomCFG.get_bounds()
	var newOffset = roomCFG.get_offset()
	
	if direction == 1:
		curPosition += Vector2(newOffset.x, newOffset.y)
	else:
		curPosition += Vector2(-newOffset.x, newOffset.y)
	
	return curPosition

func generate_rooms() -> void:
	var turned : bool = false
	
	for room in range(floorRoomCap):
		curTurnReq += 1
		if curTurnReq >= floorTurnReq:
			canTurn = true
		
		var instRoom
		var child : roomConfiguration = cfgFiles.pick_random()
		while child.roomType == roomConfiguration.Types.EXIT:
			child = cfgFiles.pick_random()
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
			instRoom = temp.instantiate()
			instRoom.position = determine_position(roomOffset, child)
			instRoom.roomFlipped = (true if direction == -1 else false)
			add_child(instRoom)
			roomOffset = instRoom.roomContObj.global_position
			if child.flipDirection:
				turned = true
				direction = -direction
			
			var addRect = Rect2(instRoom.position - (child.roomBounds/2), child.roomBounds)
			roomRects.append(addRect)

func check_collision(cfg : roomConfiguration) -> bool:
	var result : bool = false
	var size = cfg.get_bounds()
	var roomPos = determine_position(roomOffset, cfg)
	var checkShape : Rect2 = Rect2(roomPos - size/2, size)
	
	for collisions in roomRects:
		if checkShape.intersects(collisions):
			result = true
			break
	if !result:
		checkShape.position.x += (200 * direction)
		for collisions in roomRects:
			if checkShape.intersects(collisions):
				result = true
				break
	
	return result

func _draw() -> void:
	if !roomRects.is_empty():
		for rect in roomRects:
			draw_rect(rect, Color.BLUE)
	if !drawQueue.is_empty():
		for rect in drawQueue:
			draw_rect(rect, Color.RED)
		drawQueue.clear()
