extends Node2D

enum RoomNum {
	RANDOM = -1,
	ROOM_0 = 0,
	ROOM_1 = 1
}

var roomRng : RandomNumberGenerator = RandomNumberGenerator.new()
var roomGen : int = 0
var roomDir : bool = true ##FALSE is LEFT, TRUE is RIGHT
var roomRIDarray : Array = []
var roomDrawQueue : Array = []

@export var startingRoom = RoomNum.RANDOM
@export var injectNode : Node2D
@export var maxRooms : int = 25
@export var roomOffset : Vector2 = Vector2(0, 0)
@export var failAttempts : int = 64

func _ready() -> void:
	roomGen = startingRoom
	if startingRoom == -1:
		roomGen = rollRoom()
	generate_rooms()

func rollRoom() -> int:
	var roll = roomRng.randi_range(0, DataStore.roomPaths.size() - 1)
	print("roll " + str(roll))
	return roll

func generate_rooms() -> void:
	#start/setup
	var loadPath = load(DataStore.roomPaths[roomGen])
	var room = loadPath.instantiate()
	
	setup_room(room, !roomDir)
	
	injectNode.add_child.call_deferred(room)
	for roomLeft in maxRooms - 1:
		var num = rollRoom()
		loadPath = load(DataStore.roomPaths[num])
		room = loadPath.instantiate()
		var check = check_bounds(room, num)
		print_rich("[color=cyan]" + str(check))
		print_rich("[color=blue]" + str(num))
		if check != num:
			room.free()
			loadPath = load(DataStore.roomPaths[check])
			room = loadPath.instantiate()
		
		setup_room(room, !roomDir)
		
		injectNode.add_child.call_deferred(room)
	loadPath = load(DataStore.abilityPaths["END"])
	room = loadPath.instantiate()
	
	setup_room(room, !roomDir)
	
	injectNode.add_child.call_deferred(room)

func add_room_shape(child, offset, flip) -> void:
	var rectRid : Rect2
	var shapeCenter = child.roomSize / 2
	var shapePos : Vector2
	
	shapePos.y = child.roomOffset.y + offset.y
	if flip:
		shapePos.x = -(child.roomOffset.x + -offset.x)
	else:
		shapePos.x = (child.roomOffset.x + offset.x)
	
	rectRid.size = child.roomSize
	rectRid.position = shapePos
	
	#roomDrawQueue.append([shapeData, Color.PURPLE])
	roomRIDarray.append(rectRid)

func _draw() -> void:
	for rect in roomDrawQueue:
		draw_rect(rect[0], rect[1])
		#breakpoint

func setup_room(child, flip : bool) -> void:
	child.roomFlipped = flip
	
	if child.startFlipping:
		roomDir = !roomDir
	
	add_room_shape(child, roomOffset, flip)
	if flip:
		child.position.x = -(child.roomOffset.x + -roomOffset.x)
		child.position.y = (child.roomOffset.y + roomOffset.y)
		if !child.endGen:
			roomOffset.x = -(child.roomContObj.position.x - child.position.x)
			roomOffset.y = (child.roomContObj.position.y + child.position.y)
	else:
		child.position.x = (child.roomOffset.x + roomOffset.x)
		child.position.y = (child.roomOffset.y + roomOffset.y)
		if !child.endGen:
			roomOffset.x = (child.roomContObj.position.x + child.position.x)
			roomOffset.y = (child.roomContObj.position.y + child.position.y)

func check_bounds(checking, original) -> int:
	var roomInst
	var tempDir = roomDir
	var shapeRid = PhysicsServer2D.rectangle_shape_create()
	var checkingRect : Rect2
	var checkPos : Vector2 = Vector2.ZERO
	var centerPos : Vector2 = Vector2.ZERO
	var roomPass : Array[int] = []
	var conflicts : int = 0
	
	checkingRect.size = checking.roomSize
	checkPos.y = checking.roomOffset.y + roomOffset.y
	if !tempDir:
		checkPos.x = -(checking.roomOffset.x + -roomOffset.x)
	else:
		checkPos.x = (checking.roomOffset.x + roomOffset.x)
	centerPos = checkingRect.size / 2
	checkingRect.position = checkPos - centerPos
	
	roomDrawQueue.append([checkingRect, Color.FIREBRICK])
	for shape in roomRIDarray.size():
		var results = checkingRect.intersects(roomRIDarray[shape])
		if results:
			var path
			for room in DataStore.roomPaths.size():
				checkPos = Vector2.ZERO
				path = load(DataStore.roomPaths[room])
				roomInst = path.instantiate()
				
				checkingRect.size = roomInst.roomSize
				checkPos.y = roomInst.roomOffset.y + roomOffset.y
				if !tempDir:
					checkPos.x = -(roomInst.roomOffset.x + -roomOffset.x)
				else:
					checkPos.x = (roomInst.roomOffset.x + roomOffset.x)
				centerPos = checkingRect.size / 2
				checkingRect.position = checkPos - centerPos
				results = checkingRect.intersects(roomRIDarray[shape])
				if !results:
					#roomDrawQueue.append([checkingRect, Color.RED])
					#final test
					var tempOffset : Vector2 = Vector2.ZERO
					var oldDir : bool
					if tempDir:
						tempOffset = roomInst.roomContObj.position + checkPos
					else:
						tempOffset.x = -(roomInst.roomContObj.position.x - checkPos.x)
						tempOffset.y = roomInst.roomContObj.position.y + checkPos.y
					if roomInst.startFlipping:
						oldDir = !tempDir
					else:
						oldDir = tempDir
					
					for idx in DataStore.roomPaths.size():
						checkPos = Vector2.ZERO
						path = load(DataStore.roomPaths[idx])
						roomInst = path.instantiate()
						
						checkingRect.size = roomInst.roomSize
						checkPos.y = roomInst.roomOffset.y + tempOffset.y
						if !tempDir:
							checkPos.x = -(roomInst.roomOffset.x + -tempOffset.x)
						else:
							checkPos.x = (roomInst.roomOffset.x + tempOffset.x)
						centerPos = checkingRect.size / 2
						checkingRect.position = checkPos - centerPos
						
						
						results = checkingRect.intersects(roomRIDarray[shape])
						if !results:
							print("super good!")
							roomPass.append(room)
							#roomDrawQueue.append([checkingRect, Color.INDIAN_RED])
	if roomPass.size() > 0:
		var rng = RandomNumberGenerator.new()
		var roll = rng.randi_range(0, roomPass.size() - 1)
		var chosen = roomPass[roll]
		return chosen
	
	return original

#func check_bounds(checking, original) -> int:
	#var newRoom : int
	#var roomInst
	#var tempDir = roomDir
	#var shapeRid = PhysicsServer2D.rectangle_shape_create()
	#var spaceState = get_world_2d().direct_space_state
	#var centerPoint = checking.roomSize / 2
	#var checkPos : Vector2 = Vector2.ZERO
	#var queryParams = PhysicsShapeQueryParameters2D.new()
	#
	#PhysicsServer2D.shape_set_data(shapeRid, Vector2(checking.roomSize.x, checking.roomSize.y))
	#queryParams.shape_rid = shapeRid
	#queryParams.collision_mask = 10
	#queryParams.collide_with_areas = true
	#queryParams.collide_with_bodies = false
	#queryParams.margin = 0
	#
	#print(roomOffset)
	#checkPos.y = checking.roomOffset.y + roomOffset.y
	#if !tempDir:
		#checkPos.x = -(checking.roomOffset.x + -roomOffset.x)
	#else:
		#checkPos.x = (checking.roomOffset.x + roomOffset.x)
	#queryParams.transform.origin = checkPos - centerPoint
	##roomDrawQueue.append([Rect2(checkPos - centerPoint, checking.roomSize), Color.RED])
	#for att in failAttempts:
		#print_rich("[rainbow][wave]" + str(att))
		#var path
		#var oldDir = tempDir
		#var results = spaceState.intersect_shape(queryParams)
		#if results: #INDIAN ERROR
			#for cycle in DataStore.roomPaths.size():
				#queue_redraw()
				#print(cycle)
				#checkPos = Vector2.ZERO
				#path = load(DataStore.roomPaths[cycle])
				#newRoom = cycle
				#roomInst = path.instantiate()
				#if roomInst.startFlipping:
					#tempDir = !tempDir
				#else:
					#tempDir = oldDir
				#PhysicsServer2D.shape_set_data(shapeRid, Vector2(roomInst.roomSize.x, roomInst.roomSize.y))
				#centerPoint = roomInst.roomSize / 2
				#checkPos.y = roomInst.roomOffset.y + roomOffset.y
				#if !tempDir:
					#checkPos.x = -(roomInst.roomOffset.x + -roomOffset.x)
				#else:
					#checkPos.x = (roomInst.roomOffset.x + roomOffset.x)
				#queryParams.shape_rid = shapeRid
				#queryParams.transform.origin = checkPos - centerPoint
				#roomDrawQueue.append([Rect2(checkPos - centerPoint, roomInst.roomSize), Color.INDIAN_RED])
				#results = spaceState.intersect_shape(queryParams, 64)
				#print(results)
				#if !results:
					#newRoom = cycle
					### THIS IS THE LAST THORN IN MY PATH TO FREEDOM AND ENJOYMENT, PLEASE FIX THIS
					##var oldPos = Vector2.ZERO
					#var tempOffset = Vector2.ZERO
					#if tempDir:
						#tempOffset = roomInst.roomContObj.position + checkPos
						#print_rich("[shake]" + str(tempOffset))
					#else:
						#tempOffset.x = -(roomInst.roomContObj.position.x - checkPos.x)
						#tempOffset.y = roomInst.roomContObj.position.y + checkPos.y
						#print_rich("[shake]" + str(tempOffset))
					#if roomInst.startFlipping:
						#oldDir = !tempDir
					#else:
						#oldDir = tempDir
					#for idx in DataStore.roomPaths.size():
						#queue_redraw()
						#checkPos = Vector2.ZERO
						#path = load(DataStore.roomPaths[idx])
						#roomInst = path.instantiate()
						#if roomInst.startFlipping:
							#tempDir = !tempDir
						#else:
							#tempDir = oldDir
						#PhysicsServer2D.shape_set_data(shapeRid, Vector2(roomInst.roomSize.x, roomInst.roomSize.y))
						#centerPoint = roomInst.roomSize / 2
						#checkPos.y = roomInst.roomOffset.y + tempOffset.y
						#if !tempDir:
							#checkPos.x = -(roomInst.roomOffset.x + -tempOffset.x)
						#else:
							#checkPos.x = (roomInst.roomOffset.x + tempOffset.x)
						#queryParams.shape_rid = shapeRid
						#queryParams.transform.origin = checkPos - centerPoint
						#results = spaceState.intersect_shape(queryParams)
						#roomDrawQueue.append([Rect2(checkPos - centerPoint, roomInst.roomSize), Color.FIREBRICK])
						#if !results:
							#return cycle
		#else:
			#return original
	#return original
