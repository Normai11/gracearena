class_name Player
extends CharacterBody2D

## GUI scene that holds player & stage information.
@export var guiScene : PackedScene
var existingGUI
## Length of the interaction raycast stemming from the player's center position.
@export var interactionRange : float = 80.0

@export_category("Attributes")
## Maximum value of health the player can attain by default.
@export var maxHealth : float = 100.0
## Base speed the player will move at.
@export var moveSpeed : float = 760.0
var speedCap : float = 760.0
## Speed added when the player is sprinting.
@export var sprintAdditive : float = 200.0
## Y velocity value that will be set when the player jumps.
@export var jumpForce : float = 725.0
@export_group("Advanced Attributes")
## Controls whether the player can noclip or not.
@export var NOCLIP : bool = false
## Value of health the player will begin with.
@export var startHealth : float = 100.0
var health : float = 100.0
## Window (in frames) that the player can jump after falling off a platform.
@export var coyoteMax : int = 6
## Tracks frames passed after falling.
var curCoyote : int = 0
## Amount of frames the player will be invincible for after being hit.
@export var invincibilityFrames : int = 21
## Tracks frames passed after being hit.
var curIFrame : int = 0
## Maximum velocity the player can fall at.
@export var gravityCap : float = 3000.0
## Speed subtracted when the player is in a crouching state.
@export var crouchSubtractive : float = 350.0
@export var acceleration : float = 15.0
@export var friction : float = 15.0
@export var airResistance : float = 0.03
var gravity : float = ProjectSettings.get_setting("physics/2d/default_gravity")

var instantiatedPerks : Array[Perk] = []
var shieldPerk : Array = [false, 0]
var direction = 1

@onready var inputHandler : inputComponent = $inputComponent
@onready var colliderStand : CollisionShape2D = $collisionStand
@onready var colliderCrouch : CollisionShape2D = $collisionCrouch
@onready var standDetect : RayCast2D = $standDetect
@onready var interactDetect : RayCast2D = $interactDetect

func _ready() -> void:
	var instanceGUI = guiScene.instantiate()
	instanceGUI.playerNode = self
	add_child(instanceGUI)
	existingGUI = instanceGUI
	
	for perk in DataStore.saveData["activePerks"]:
		add_perk(perk)

func add_perk(perk) -> void:
	var perkLoad = load(DataStore.perkPaths[perk])
	var perkChild : Perk = perkLoad.instantiate()
	perkChild.playerParent = self
	existingGUI.perkContainer.add_child(perkChild)
	instantiatedPerks.append(perkChild)
	if perkChild.perkName == "Shield":
		shieldPerk[0] = true
		shieldPerk[1] = instantiatedPerks.find(perkChild)

func _physics_process(delta: float) -> void:
	process_movement(delta)
	process_interaction()
	$Label.text = str(speedCap) + "\n" + str(velocity.x)

func _process(_delta: float) -> void:
	if NOCLIP:
		colliderStand.disabled = true
		colliderCrouch.disabled = true
	
	if curIFrame > 0:
		modulate.a = 0.5
		curIFrame -= 1
	else:
		modulate.a = 1

func process_movement(delta) -> void:
	if NOCLIP:
		process_submovement_NOCLIP(delta)
		return
	var movement = inputHandler.get_movement_input()
	var speed = speedCap + (sprintAdditive if Input.is_action_pressed("sprint") else 0.0)
	var velocityWeight : float = delta * (acceleration if movement or inputHandler.downState == 2 else friction)
	var justSlide : bool = false
	
	if movement != 0:
		interactDetect.target_position.x = interactionRange * direction
		if !inputHandler.downState == 2:
			direction = movement
	
	if Input.is_action_just_pressed("crouch") && Input.is_action_pressed("sprint"):
		inputHandler.downState = 2
		colliderCrouch.disabled = false
		colliderStand.disabled = true
		speed += sprintAdditive * 2 * movement
		justSlide = true
	elif Input.is_action_pressed("crouch"):
		if inputHandler.downState < 2:
			inputHandler.downState = 1
			colliderCrouch.disabled = false
			colliderStand.disabled = true
			speed -= crouchSubtractive
	else:
		if !standDetect.is_colliding():
			inputHandler.downState = 0
			colliderStand.disabled = false
			colliderCrouch.disabled = true
		else:
			speed -= crouchSubtractive
	
	if inputHandler.downState == 2 && !justSlide:
		if is_on_wall():
			direction = -direction
		movement = direction
		speed = speedCap + sprintAdditive
	velocity.x = lerp(velocity.x, movement * speed, velocityWeight)
	
	if !is_on_floor():
		curCoyote += 1
		if inputHandler.curJumps == 0 && curCoyote >= coyoteMax:
			inputHandler.curJumps += 1
	if inputHandler.get_can_jump() && Input.is_action_just_pressed("jump"):
		velocity.y = -jumpForce
		inputHandler.curJumps += 1
	
	velocity.y += gravity * delta
	if velocity.y >= gravityCap:
		velocity.y = gravityCap
	if !Input.is_action_pressed("jump") && !is_on_floor():
		velocity.y = lerp(velocity.y, gravity, 0.02)
	
	move_and_slide()
	
	if is_on_floor():
		inputHandler.curJumps = 0
		curCoyote = 0
		if inputHandler.downState == 2:
			var floorNormal = get_floor_normal()
			if floorNormal.y > -0.999:
				speedCap += (floorNormal.x * 22) * movement
		else:
			speedCap = moveSpeed
	else:
		speedCap = lerp(speedCap, moveSpeed, airResistance)
		#if speedCap >= moveSpeed:
			#speedCap = moveSpeed

func process_submovement_NOCLIP(delta : float) -> void:
	var movement : Vector2 = Vector2(inputHandler.get_movement_input(), Input.get_axis("jump", "crouch"))
	var speed = 2 * (moveSpeed + sprintAdditive)
	var velocityWeight : float = delta * (acceleration if movement else friction)
	
	velocity.x = lerp(velocity.x, movement.x * speed, velocityWeight)
	velocity.y = lerp(velocity.y, movement.y * speed, velocityWeight)
	
	move_and_slide()

func process_interaction() -> void:
	if interactDetect.is_colliding():
		var rayCollision : Interactable = interactDetect.get_collider()
		
		if existingGUI.showInteraction == false:
			existingGUI.set_interactPrompt(true, rayCollision.promptName)
		
		if Input.is_action_just_pressed("interact"):
			rayCollision._interacted()
	else:
		existingGUI.set_interactPrompt(false)

func damage_player(amount : float, hurtDirection : int, knockback : float = 0.0, penetrable : bool = false) -> void:
	if shieldPerk[0]:
		var perk : Perk = instantiatedPerks[shieldPerk[1]]
		if !perk.onCooldown && !penetrable:
			perk._activate_perk()
			return
	if curIFrame > 0:
		return
	
	health -= amount
	velocity.x += knockback * hurtDirection
	curIFrame = invincibilityFrames
