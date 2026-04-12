@tool
extends Node2D

enum typeDisplay {
	RANDOM = -1,
	basicPatroller = 0,
	enemySpore = 1
}

var enemyRef : Dictionary[int, String] = {
	0 : "res://assets/characters/basicPatroller.tscn",
	1 : "res://assets/characters/enemySpore.tscn"
}

##Must be float values between 0.0 and 1.0
@export var enemyChances : Dictionary[String, float] = {
	"basicPatroller" : 0.75,
	"enemySpore" : 0.25
}
var enemyWeights : PackedFloat32Array

var randGen : RandomNumberGenerator = RandomNumberGenerator.new()

## If true, this node will not spawn anything and free itself from the scene tree immediately.
@export var disabled : bool = false
## The enemy this node will spawn when the scene is loaded.
@export var enemyType = typeDisplay.RANDOM
## The direction the enemy will face when loaded into the scene. -1 is left, 1 is right.
@export_range(-1, 1, 2) var spawnDirection : int = 1
@export_category("Custom Attributes")
## Enabling this overrides the enemy's preset attributes.
@export var overrideAttributes : bool = false
## The max amount of health the enemy will recieve.
@export var customHealth : float = 5.0
## The amount of damage the enemy will inflict on the player.
@export var customDamage : float = 5.0
## The speed that the enemy will be granted.
@export var customSpeed : float = 200.0

func _ready() -> void:
	if !Engine.is_editor_hint():
		if disabled:
			self.queue_free()
			return
		var enemyPath
		
		enemyWeights = PackedFloat32Array(enemyChances.values())
		
		if enemyType == -1 or enemyType == 1028:
			var refValues = enemyRef.values()
			var randEnemy = refValues[randGen.rand_weighted(enemyWeights)]
			#enemyPath = load(enemyRef[randEnemy])
			enemyPath = load(randEnemy)
		else:
			enemyPath = load(enemyRef[enemyType])
		var enemyChild = enemyPath.instantiate()
		
		enemyChild.global_position = self.global_position
		enemyChild.startingDirection = spawnDirection
		if overrideAttributes:
			enemyChild.health = customHealth
			enemyChild.moveSpeed = customSpeed
			enemyChild.dmg = customDamage
		
		get_tree().current_scene.add_child.call_deferred(enemyChild)
		self.queue_free()

func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		if spawnDirection == 1:
			$EnemySpawner.flip_h = true
		else:
			$EnemySpawner.flip_h = false
