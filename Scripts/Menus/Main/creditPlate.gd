extends Control

#LINK REF: 0 = YT 1 = X 2 = Blu 3 = Twitch 4 = Tik 5 = Insta
@export var iconPath : String
@export var plateName : String
@export var plateRole : String
@export var plateDesc : String
@export var Links : Array = [0, 1, 2, 3, 4]
@export var extraLink : Array = [""]
@export var URL : Array = [""]
var plateID : int

func _ready() -> void:
	name = "plate" + str(plateID)
	var desc = plateName + "\n" + plateRole + "\n" + plateDesc
	$Plate/Icon.texture = load(str(iconPath))
	$Plate/Description.text = desc
	for item in Links:
		var subject = $Plate/Links.get_child(item)
		subject.disabled = false
		subject.visible = true
	#extra

func _Tik_pressed() -> void:
	OS.shell_open(URL[4])
