extends Node2D

enum glareStates {
	CLOSED,
	OPEN,
	ATTACKING
}

var glareSpriteRegions = {
	0 : Rect2(0.0, 0.0, 287, 479),
	1 : Rect2(287, 0.0, 287, 479),
	2 : Rect2(574, 0.0, 287, 479)
}

@export var dragMult : float = 0.15
@export var waitRange : Vector2 = Vector2(8.0, 55.0)
@export var openDuration : float = 15.0

var playerTarget : Player
var curGlare : glareStates = glareStates.CLOSED
var curTimer : float = 0.0
var glareMercy : float = 0.2

func set_atlas_region(regionData : Rect2, texture) -> void:
	var atlas = texture.texture
	atlas.region = Rect2(regionData)

func _ready() -> void:
	curTimer = randf_range(waitRange.x, waitRange.y)

func _process(delta: float) -> void:
	position = lerp(position, playerTarget.position, dragMult)
	
	glare_function(delta)

func glare_function(delta : float) -> void:
	curTimer -= delta
	
	if curGlare == glareStates.CLOSED:
		set_atlas_region(glareSpriteRegions[0], $Appearance/body)
		position.y += 20
		if curTimer <= 0:
			curGlare = glareStates.OPEN
			curTimer = openDuration
	else:
		if curGlare == glareStates.OPEN:
			if curTimer <= 0:
				end_glare()
			
			if !playerTarget.glareSafe && curTimer <= openDuration - 0.8:
				glareMercy -= delta
				set_atlas_region(glareSpriteRegions[2], $Appearance/body)
				if glareMercy <= 0:
					if glareMercy <= -0.2:
						glareMercy = 0
						playerTarget.damage_by(3.34, 0, false, true)
			else:
				set_atlas_region(glareSpriteRegions[1], $Appearance/body)
				glareMercy = 0.2

func start_glare() -> void:
	pass

func end_glare() -> void:
	curTimer = randf_range(waitRange.x, waitRange.y)
	curGlare = glareStates.CLOSED
