extends Control

var CurrentMenu : int = 0

@onready var categoryParent = $Categories
@onready var categoryGame = $catGame

@onready var transSlider = $catGame/guiTransSlider

func _ready() -> void:
	switchMenu(0)
	transSlider.value = DataStore.settings["guiTrans"]

func _process(_delta: float) -> void:
	var sliderValStr = str(int(transSlider.value * 100)) + "%"
	DataStore.settings["guiTrans"] = transSlider.value
	transSlider.get_child(0).text = sliderValStr
	transSlider.get_child(1).self_modulate.a = DataStore.settings["guiTrans"]

func switchMenu(menu : int = 0) -> void:
	categoryParent.visible = false
	categoryGame.visible = false
	position = Vector2(0, 0)
	CurrentMenu = menu
	if menu == 0:
		categoryParent.visible = true
		position = Vector2(-784, 0)
	elif menu == 3:
		categoryGame.visible = true

func _Game_Open() -> void:
	switchMenu(3)

func _Return() -> void:
	if CurrentMenu != 0:
		switchMenu(0)
	else:
		queue_free()
