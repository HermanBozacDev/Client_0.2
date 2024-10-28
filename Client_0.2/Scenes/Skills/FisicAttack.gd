extends Area2D
var processing_body = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	await (get_tree().create_timer(0.2).timeout)
	queue_free()


func _on_body_entered(body: Node2D) -> void:
	if processing_body == false:
		processing_body = true
		print("colision ahora si con body")
		get_node("CollisionShape2D").set_deferred("disabled", true)
		self.hide()
	else:
		return
