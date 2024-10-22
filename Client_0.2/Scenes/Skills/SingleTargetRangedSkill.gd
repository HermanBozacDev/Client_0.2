extends RigidBody2D



var projectile_speed 
var life_time = 3
var skill_name


func _ready():
	$AnimatedSprite2D.play("Fireball")
	apply_central_impulse(Vector2(200, 0).rotated(rotation))
	SelfDestruct()
func SelfDestruct():
	await(get_tree().create_timer(life_time).timeout)
	queue_free()


func _on_body_entered(_body: Node) -> void:
	get_node("CollisionShape2D").set_deferred("disabled", true)
	self.hide()
