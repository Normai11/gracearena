@tool
@icon("res://Assets/Templates/RoomManager.svg")
class_name RoomManager
extends Node2D

#@export_tool_button("Generate rooms", "Add") var targetGen : Callable = generate_rooms
## Press this variable to generate rooms through the inspector WHILE RUNNING.
#@export var Generate_Rooms : bool = false:
	#set(value):
		#generate_rooms()
@export var genOffset : Vector2 = Vector2.ZERO:
	set(position):
		genOffset = position
		global_position = genOffset
@export_range(-1, 1, 2) var genDirection : int = 1

@export_group("Generation Settings", "set")
@export_dir var setCFGFolderPath : String
@export var setGenAmount : int = 22

var CFGStorage : Dictionary[int, Array] = {
	0 : [], ## "Timer" rooms - Array MUST consist only of RoomConfiguration type
	1 : [], ## "Saferoom" rooms - Array MUST consist only of RoomConfiguration type
	2 : [], ## Room chances - Array MUST consist only of float type
	3 : [], ## ALL rooms (for reference) - Array MUST consist only of RoomConfiguration type
}
var roomStorage : Array[Room] = []
var drawReq : Array[Rect2] = []
var genFinished : bool = true

func _ready() -> void:
	if Engine.is_editor_hint():
		return
	_preload_roomCFGs(-1)
	
	#generate_rooms()

func _process(_delta: float) -> void:
	if Engine.is_editor_hint():
		genOffset = global_position

func _preload_roomCFGs(biome : int) -> void:
	var search = DirAccess.open(setCFGFolderPath)
	var fileGet = search.get_files()
	for file in fileGet:
		var loadCheck = load(setCFGFolderPath + "/" + file)
		if loadCheck is RoomConfiguration:
			match loadCheck.roomType:
				0:
					CFGStorage[0].append(loadCheck)
				1:
					CFGStorage[1].append(loadCheck)
			CFGStorage[2].append(loadCheck.roomChance)
			CFGStorage[3].append(loadCheck)
		else:
			printerr("File " + file + " is not a RoomConfiguration resource.")

func pick_room(roomType : int = 0) -> RoomConfiguration:
	var pickRNG : RandomNumberGenerator = RandomNumberGenerator.new()
	var result : int
	var OK : bool = false
	
	while !OK:
		# picks a random room from the chance array
		result = pickRNG.rand_weighted(CFGStorage[2])
		# checks if the value chosen is a Timer roomtype
		if CFGStorage[3][result].roomType == roomType:
			OK = true
	return CFGStorage[roomType][result]

func determine_room_position(curOffset : Vector2, roomCFG : RoomConfiguration) -> Vector2:
	var roomPos : Vector2 = curOffset
	var roomOffset : Vector2 = roomCFG._get_offset()
	
	# takes the curOffset (often the genOffset) and adds the roomOffset to align it properly
	if genDirection == 1:
		roomPos += Vector2(roomOffset.x, roomOffset.y)
	else:
		#flips only the x axis
		roomPos += Vector2(-roomOffset.x, roomOffset.y)
	
	return roomPos

func check_room_placement(compareList : Array[Rect2], compareSubject : Rect2) -> bool:
	for rect in compareList:
		if compareSubject.intersects(rect):
			#printerr("Room failed to place")
			return false
	#drawReq.append(compareSubject)
	#queue_redraw()
	return true

func generate_rooms(amount : int = setGenAmount) -> void:
	var rectStorage : Array[Rect2] = []
	genFinished = false
	for room in amount:
		var roomOK : bool = false
		var instRoom : RoomConfiguration
		var roomRect : Rect2
		var roomAttempt : int = 0
		var roomSearchIdx : int = 0
		
		while !roomOK:
			# pick and get roomConfiguration data
			if roomAttempt == 0:
				instRoom = pick_room(0)
			else:
				instRoom = pick_room(0)
				#instRoom = CFGStorage[0][roomSearchIdx]
			# set checker size & position
			var rectSize : Vector2 = instRoom.roomSize
			var rectPos : Vector2 = determine_room_position(genOffset, instRoom)
			roomRect = Rect2(rectPos - (rectSize/2), rectSize - Vector2(50, 50))
			#drawReq.append(roomRect)
			#queue_redraw()
			# compare checker room for "existing" rooms
			# (only compares existing boundaries in rectStorage, free pass if array is empty)
			var checkResult = check_room_placement(rectStorage, roomRect)
			if checkResult:
				roomOK = true
				roomAttempt = 0
				roomSearchIdx = 0
				break
			await get_tree().process_frame
			roomAttempt += 1
			roomSearchIdx += 1
		# add rect for future comparisons
		rectStorage.append(roomRect)
		
		place_room(instRoom)
	genFinished = true

func place_room(roomCFG : RoomConfiguration) -> void:
	var child : Room
	var loadPath = load(roomCFG.roomScenePath)
	child = loadPath.instantiate()
	
	child.position = determine_room_position(genOffset, roomCFG)
	if genDirection == -1:
		child.roomFlipped = true
	
	get_tree().current_scene.add_child.call_deferred(child)
	roomStorage.append(child)
	await get_tree().process_frame
	# sets room offset to the point where next room will be generated (set inside Room nodes)
	genOffset = child.roomContinueMarker.global_position
	
	if roomCFG.roomFlips:
		genDirection = -genDirection

#func _draw() -> void:
	#for request in drawReq:
		#draw_rect(request, Color.RED)
	#drawReq.clear()
