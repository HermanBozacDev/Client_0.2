extends AnimatedSprite2D


"""INIT"""
func _ready() -> void:
	play("default")

"""BORRAR NODO AL TERMINAR ANIMACION"""
func _on_animation_finished() -> void:
	queue_free()
