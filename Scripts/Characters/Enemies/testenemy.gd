extends Enemy

var tween : Tween

func _physics_process(delta: float) -> void:
	bodyRef.velocity.y += gravity * delta
	bodyRef.move_and_slide()

func body_check(body: Node2D) -> void:
	if body is Player:
		if body.iFrames == 0:
			body.damage_by(dmg, direction)

func damage_by(amt, dir):
	knockback(800 * dir)
	health -= amt
	if health <= 0:
		queue_free()

func knockback(amt):
	bodyRef.velocity.x = amt
	
	if tween:
		tween.kill()
	tween = get_tree().create_tween()
	tween.tween_property(bodyRef, "velocity", Vector2(0, 0), 0.1)
