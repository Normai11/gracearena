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

@export var startingRoom = RoomNum.RANDOM
@export var injectNode : Node2D
@export var maxRooms : int = 25
@export var roomOffset : Vector2 = Vector2(0, 0)

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
	add_room_shape(room)
	
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
		add_room_shape(room)
		
		injectNode.add_child.call_deferred(room)
	loadPath = load(DataStore.abilityPaths["END"])
	room = loadPath.instantiate()
	
	setup_room(room, !roomDir)
	
	injectNode.add_child.call_deferred(room)

func add_room_shape(child) -> void:
	var areaRid = PhysicsServer2D.area_create()
	var shapeRid = PhysicsServer2D.rectangle_shape_create()
	var spaceState = get_world_2d().direct_space_state
	PhysicsServer2D.shape_set_data(shapeRid, Vector2(child.roomSize.x, child.roomSize.y))
	PhysicsServer2D.area_set_collision_layer(areaRid, 10)
	PhysicsServer2D.area_set_collision_mask(areaRid, 0)
	PhysicsServer2D.area_set_monitorable(areaRid, true)
	PhysicsServer2D.area_set_space(areaRid, spaceState)
	
	if !roomDir:
		PhysicsServer2D.area_add_shape(areaRid, shapeRid, Transform2D(0, Vector2(-(child.roomOffset.x + -roomOffset.x), child.roomOffset.y + roomOffset.y)))
	else:
		PhysicsServer2D.area_add_shape(areaRid, shapeRid, Transform2D(0, Vector2(child.roomOffset.x + roomOffset.x, child.roomOffset.y + roomOffset.y)))
	
	roomRIDarray.append(areaRid)

func setup_room(child, flip : bool) -> void:
	child.roomFlipped = flip
	
	if child.startFlipping:
		roomDir = !roomDir
	
	if flip:
		child.position.x += -(child.roomOffset.x + -roomOffset.x)
		child.position.y += (child.roomOffset.y + roomOffset.y)
		if !child.endGen:
			roomOffset.x = -(child.roomContObj.position.x - child.position.x)
			roomOffset.y = (child.roomContObj.position.y + child.position.y)
	else:
		child.position.x += (child.roomOffset.x + roomOffset.x)
		child.position.y += (child.roomOffset.y + roomOffset.y)
		if !child.endGen:
			roomOffset.x = (child.roomContObj.position.x + child.position.x)
			roomOffset.y = (child.roomContObj.position.y + child.position.y)

func check_bounds(checking, original) -> int:
	var newRoom : int
	var roomInst
	var tempDir = roomDir
	var shapeRid = PhysicsServer2D.rectangle_shape_create()
	var spaceState = get_world_2d().direct_space_state
	PhysicsServer2D.shape_set_data(shapeRid, Vector2(checking.roomSize.x, checking.roomSize.y))
	
	var queryParams = PhysicsShapeQueryParameters2D.new()
	queryParams.shape_rid = shapeRid
	queryParams.collision_mask = 10
	queryParams.collide_with_areas = true
	
	if !roomDir:
		queryParams.transform = (Transform2D(0, Vector2(-(checking.roomOffset.x + -roomOffset.x), checking.roomOffset.y + roomOffset.y)))
	else:
		queryParams.transform = (Transform2D(0, Vector2(checking.roomOffset.x + roomOffset.x, checking.roomOffset.y + roomOffset.y)))
	
	for attempts in 96:
		var path
		var results = spaceState.intersect_shape(queryParams)
		var uncDir = tempDir
		if results:
			for index in DataStore.roomPaths.size():
				print("awesome")
				print("index" + str(index))
				path = load(DataStore.roomPaths[index])
				newRoom = index
				roomInst = path.instantiate()
				if roomInst.startFlipping:
					tempDir = !tempDir
				else:
					tempDir = uncDir
				PhysicsServer2D.shape_set_data(shapeRid, Vector2(roomInst.roomSize.x, roomInst.roomSize.y))
				if !tempDir:
					queryParams.transform = (Transform2D(0, Vector2(-(roomInst.roomOffset.x + -roomOffset.x), roomInst.roomOffset.y + roomOffset.y)))
				else:
					queryParams.transform = (Transform2D(0, Vector2(roomInst.roomOffset.x + roomOffset.x, roomInst.roomOffset.y + roomOffset.y)))
				queryParams.shape_rid = shapeRid
				results = spaceState.intersect_shape(queryParams)
				if !results:
					var tempOffset = roomInst.roomContObj.position
					uncDir = tempDir
					for idx in DataStore.roomPaths.size():
						print("second check begin")
						path = load(DataStore.roomPaths[idx])
						roomInst = path.instantiate()
						if roomInst.startFlipping:
							tempDir = !tempDir
						else:
							tempDir = uncDir
						PhysicsServer2D.shape_set_data(shapeRid, Vector2(roomInst.roomSize.x, roomInst.roomSize.y))
						if !tempDir:
							queryParams.transform = (Transform2D(0, Vector2(-(roomInst.roomOffset.x + -tempOffset.x), roomInst.roomOffset.y + tempOffset.y)))
						else:
							queryParams.transform = (Transform2D(0, Vector2(roomInst.roomOffset.x + tempOffset.x, roomInst.roomOffset.y + tempOffset.y)))
						queryParams.shape_rid = shapeRid
						results = spaceState.intersect_shape(queryParams)
						if !results:
							print("room passed " + str(idx))
							return newRoom
		else:
			return original
		
	return original
