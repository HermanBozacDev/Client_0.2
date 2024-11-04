extends Area2D
var processing_body = false

"""INIT """
func _ready() -> void:
	await (get_tree().create_timer(0.2).timeout)
	queue_free()

"""HANDLE COLLISION"""
func _on_body_entered(_body: Node2D) -> void:
	if processing_body == false:
		processing_body = true
		get_node("CollisionShape2D").set_deferred("disabled", true)
		self.hide()
	else:
		return
