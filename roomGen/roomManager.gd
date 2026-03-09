@tool
extends Node2D

enum biomes {
	biomeTest
}

## May tamper with export variables. Use with caution!
@export_tool_button("Test Generation (IN-EDITOR)", "Warning") var target = editor_gen_test
@export_tool_button("Reset Tamper-probable Values", "CodeEdit") var targetClear = editor_gen_cleanse

@export var roomOffset = Vector2.ZERO
@export_group("Floor Configuration", "floor")
@export var floorBiome : biomes = biomes.biomeTest
@export var floorRoomCap : int = 15

var drawQueue : Array = []
var direction : int = 1 ## 1 is RIGHT, -1 is LEFT
var roomRects : Array = []

func editor_gen_test() -> void:
	#print("haha i do nothing right now")
	generate_rooms()

func editor_gen_cleanse() -> void:
	roomOffset = Vector2.ZERO
	direction = 1
	roomRects.clear()

func _ready() -> void:
	if Engine.is_editor_hint():
		return
	generate_rooms()

func determine_position(curOffset : Vector2, roomProperties) -> Vector2:
	var curPosition = curOffset
	var roomSize = roomProperties.roomSize
	var lesserRoomOffset = roomProperties.roomOffset
	
	if direction == 1:
		curPosition += Vector2(lesserRoomOffset.x, lesserRoomOffset.y)
	else:
		curPosition += Vector2(-lesserRoomOffset.x, lesserRoomOffset.y)
	
	return curPosition

func generate_rooms() -> void:
	var roomPaths : Array
	for path in DataStore.biomeTest.values():
		roomPaths.append(load(path))
	
	for index in range(floorRoomCap):
		var instRoom
		var child0 = roomPaths.pick_random().instantiate()
		var result0 = check_collision(determine_position(roomOffset, child0), child0.roomSize, child0)
		if !result0:
			instRoom = child0
		else:
			for rooms in roomPaths:
				var path = rooms
				var child = path.instantiate()
				var result = check_collision(determine_position(roomOffset, child), child.roomSize, child)
				if !result:
					instRoom = child
					break
				else:
					printerr("Room with index " + str(index) + " failed check. Continuing through iterations.")
		if instRoom == null:
			printerr("All room iterations failed. Proceeding to next check...")
			continue
		
		instRoom.position = determine_position(roomOffset, instRoom)
		instRoom.roomFlipped = (true if direction == -1 else false)
		add_child(instRoom)
		roomOffset = instRoom.roomContObj.global_position
		if instRoom.startFlipping:
			direction = -direction
		
		var addRect = Rect2(instRoom.position - instRoom.roomSize/2, instRoom.roomSize)
		roomRects.append(addRect)
		queue_redraw()

func check_collision(position : Vector2, size : Vector2, roomNode) -> bool:
	var roomRect = Rect2(position - size / 2, size)
	var futureRect = Rect2(position, size)
	if direction == 1:
		futureRect.position += roomNode.roomContObj.global_position
	else:
		futureRect.position.x += -roomNode.roomContObj.global_position.x
		futureRect.position.y += roomNode.roomContObj.global_position.y
	
	if roomRects.is_empty():
		return false
	
	drawQueue.append(futureRect)
	
	for rect in roomRects:
		if roomRect.intersects(rect):
			return true
		#if futureRect.intersects(rect):
			#return true
	return false

func _draw() -> void:
	if !drawQueue.is_empty():
		for rect in drawQueue:
			draw_rect(rect, Color.RED)
		drawQueue.clear()
	if !roomRects.is_empty():
		for rect in roomRects:
			draw_rect(rect, Color.BLUE)
