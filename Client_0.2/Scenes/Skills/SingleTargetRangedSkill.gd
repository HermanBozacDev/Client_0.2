extends RigidBody2D

var projectile_speed 
var life_time = 3
var skill_name
var processing_body = false

"""INIT"""
func _ready():
	$AnimatedSprite2D.play(skill_name)
	apply_central_impulse(Vector2(200, 0).rotated(rotation))
	SelfDestruct()

"""BORRAR NODO"""
func SelfDestruct():
	await(get_tree().create_timer(life_time).timeout)
	queue_free()

"""HANDLE COLLISION WITH BODY"""
func _on_skill_hitbox_body_entered(body: Node2D) -> void:
	if processing_body == false:
		processing_body = true
		get_node("CollisionShape2D").set_deferred("disabled", true)
		self.hide()
		var hit_effect = load("res://Scenes/Skills/HitEffect.tscn").instantiate()
		var new_class = (body.get_class())
		match new_class:
			"TileMapLayer":
				hit_effect.position = get_global_position()
				body.add_child(hit_effect)
			"CharacterBody2D":
				body.add_child(hit_effect)
	else:
		return
