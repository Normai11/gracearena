extends Perk

@export var dropVelocity : float = 900.0

@onready var texture = $Display

func _ready() -> void:
	super._ready()

func _physics_process(_delta: float) -> void:
	texture.scale = lerp(texture.scale, Vector2.ONE, 0.5)
	if !onCooldown:
		texture.material.set_shader_parameter("saturation_mult", 1)
		texture.material.set_shader_parameter("value_mult", 1)
		if Input.is_action_pressed("crouch"):
			playerParent.set_collision_mask_value(5, false)
		else:
			playerParent.set_collision_mask_value(5, true)
		if !playerParent.is_on_floor() && Input.is_action_just_pressed("crouch"):
			if abs(playerParent.velocity.x) > 300:
				_activate_perk()
			else:
				_activate_perk(1)
	else:
		texture.material.set_shader_parameter("saturation_mult", 0.7)
		texture.material.set_shader_parameter("value_mult", 0.7)
		if playerParent.is_on_floor():
			onCooldown = false

func _activate_perk(type : int = 0) -> void:
	super._activate_perk()
	
	texture.scale = Vector2(1.25, 1.25)
	if type == 0:
		playerParent.velocity.y = dropVelocity
	else:
		playerParent.velocity.y = playerParent.gravityCap
