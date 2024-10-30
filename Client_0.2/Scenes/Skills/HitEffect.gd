extends AnimatedSprite2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	play("default")



func _on_animation_finished() -> void:
	print("finish")
	queue_free()
