extends interactableObject

@export var loadTimeCap : float = 0.25

var shopOpened : bool = false
var curTime : float = 0.0
var shopChild : Node
var preOpenValues : Array = [0, 0, 0]

var pathInstantiated : bool = false
@onready var shopPath := preload("res://assets/shopkeeper/shopParent.tscn")
@onready var area = $interactionArea

func _ready() -> void:
	curTime = loadTimeCap

func _interacted():
	shopOpened = true
	if overhaulCamera:
		var camera = get_parent().find_child("advCamera")
		preOpenValues[0] = camera.cameraType
		preOpenValues[1] = camera.curTarget
		preOpenValues[2] = camera.targetZoom
		camera.change_targets(self, cameraFocusMode, cameraFocusDrag, cameraFocusZoom)
	area.monitorable = false

func _process(delta: float) -> void:
	if shopOpened:
		curTime -= delta
		if curTime <= 0:
			curTime = 0
			if !pathInstantiated:
				pathInstantiated = true
				open_shop()
	else:
		curTime = loadTimeCap

func open_shop() -> void:
	var shop = shopPath.instantiate()
	var playerHUD = get_parent().find_child("Player")
	if playerHUD:
		playerHUD.moveType = 5
		playerHUD = playerHUD.guiScene
		playerHUD.shop_toggle(true)
	
	add_child(shop)
	shopChild = shop

func close_shop() -> void:
	var playerHUD = get_parent().find_child("Player")
	var camera = get_parent().find_child("advCamera")
	
	shopChild.queue_free()
	camera.change_targets(preOpenValues[1], preOpenValues[0], 0.4, preOpenValues[2])
	
	if playerHUD:
		playerHUD.moveType = 0
		playerHUD = playerHUD.guiScene
		playerHUD.shop_toggle(false)
	
	pathInstantiated = false
	area.monitorable = true
	shopOpened = false
