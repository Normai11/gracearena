extends Perk

@export var setIFrames : int = 35

@onready var texture : TextureRect = $Display
@onready var cdDisplay : Label = $Display/cdDisplay

func _ready() -> void:
	super._ready()

func _activate_perk() -> void:
	super._activate_perk()
	playerParent.curIFrame = setIFrames
	texture.scale = Vector2(1.25, 1.25)
	texture.material.set_shader_parameter("saturation_mult", 0.7)
	texture.material.set_shader_parameter("value_mult", 0.7)

func _process(delta: float) -> void:
	if onCooldown:
		curCooldown -= delta
		cdDisplay.text = str(snapped(curCooldown, 0.1))
		cdDisplay.visible = true
		if curCooldown <= 0.0:
			onCooldown = false
			texture.scale = Vector2(1.25, 1.25)
			texture.material.set_shader_parameter("saturation_mult", 1)
			texture.material.set_shader_parameter("value_mult", 1)
	else:
		cdDisplay.visible = false
	texture.scale = lerp(texture.scale, Vector2.ONE, 0.5)
