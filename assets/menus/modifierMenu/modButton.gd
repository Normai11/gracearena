@tool
class_name ModifierButton
extends Control

@onready var displayIcon : TextureRect = $icon
@onready var displayName : RichTextLabel = $modName
@onready var displayDesc : RichTextLabel = $modDesc

enum modIcons {
	PLACEHOLDER = -1,
	STOPLYTE = 0,
	GLARE = 1,
	STARGAZER = 2
}

var iconRects : Dictionary[int, Rect2] = {
	-1 : Rect2(0, 0, 200, 200),
	0 : Rect2(200, 0, 200, 200),
	1 : Rect2(400, 0, 200, 200),
	2 : Rect2(600, 0, 200, 200),
}

@export var modifierName : String:
	set(modName):
		modifierName = modName
		if modName:
			displayName.text = modName
		else:
			displayName.text = "Modifier Name [color=yellow]+XP%"
@export_multiline var modifierDescription : String:
	set(modDesc):
		modifierDescription = modDesc
		if modDesc:
			displayDesc.text = modDesc
		else:
			displayDesc.text = "Short Description"
@export var modifierIcon : modIcons = modIcons.PLACEHOLDER:
	set(icon):
		modifierIcon = icon
		displayIcon.texture.region = iconRects[icon]

#func _get_property_list() -> Array[Dictionary]:
	#var properties : Array[Dictionary] = []
	#
	#if modifierIcon:
		#properties.append({
			#"name" : "customAtlasRegion",
			#"type" : TYPE_RECT2,
			#"usage" : PROPERTY_USAGE_DEFAULT
		#})
		#properties.append({
			#"name" : "customIconAtlas",
			#"type" : TYPE_OBJECT,
			#"hint": PROPERTY_HINT_RESOURCE_TYPE,
			#"hint_string": "AtlasTexture",
			#"usage" : PROPERTY_USAGE_DEFAULT
		#})
	#
	#return properties
