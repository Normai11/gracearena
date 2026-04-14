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
@export var active : bool = false
@export var waitRange : Vector2 = Vector2(8.0, 55.0)
@export var openDuration : float = 15.0
@export var tickDamage : float = 2.75
@export var mercyTimer : float = 0.5
@export var tickRate : float = 0.2

var playerTarget : Player
var curGlare : glareStates = glareStates.CLOSED
var curTimer : float = 0.0
var glareMercy : float

func modifier_set_active(activate : bool = true) -> void:
	active = activate
	end_glare()

func set_atlas_region(regionData : Rect2, texture) -> void:
	var atlas = texture.texture
	atlas.region = Rect2(regionData)

func _ready() -> void:
	#curTimer = randf_range(waitRange.x, waitRange.y)
	glareMercy = mercyTimer

func _process(delta: float) -> void:
	if active:
		position = lerp(position, playerTarget.position, dragMult)
		
		glare_function(delta)

func glare_function(delta : float) -> void:
	curTimer -= delta
	
	if curGlare == glareStates.CLOSED:
		set_atlas_region(glareSpriteRegions[0], $Appearance/body)
		position.y += 20
		if curTimer <= 0:
			start_glare()
			return
	else:
		if curGlare == glareStates.OPEN:
			if curTimer <= 0:
				end_glare()
				return
			
			if !playerTarget.glareSafe && curTimer <= openDuration - 1:
				glareMercy -= delta
				set_atlas_region(glareSpriteRegions[2], $Appearance/body)
				if glareMercy <= 0:
					if glareMercy <= -tickRate:
						glareMercy = 0
						playerTarget.damage_by(tickDamage, 0, false, true)
			else:
				set_atlas_region(glareSpriteRegions[1], $Appearance/body)
				glareMercy = mercyTimer

func start_glare() -> void:
	curGlare = glareStates.OPEN
	curTimer = openDuration

func end_glare() -> void:
	curTimer = randf_range(waitRange.x, waitRange.y)
	curGlare = glareStates.CLOSED
