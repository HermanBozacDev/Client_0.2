extends RigidBody2D



var projectile_speed 
var life_time = 3
var skill_name
var processing_body = false


func _ready():
	$AnimatedSprite2D.play(skill_name)
	apply_central_impulse(Vector2(200, 0).rotated(rotation))
	SelfDestruct()
func SelfDestruct():
	await(get_tree().create_timer(life_time).timeout)
	queue_free()


func _on_skill_hitbox_body_entered(body: Node2D) -> void:
	if processing_body == false:
		processing_body = true
		print("colision ahora si con body")
		get_node("CollisionShape2D").set_deferred("disabled", true)
		self.hide()
	else:
		return
