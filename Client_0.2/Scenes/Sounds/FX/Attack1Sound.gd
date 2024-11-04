extends AudioStreamPlayer2D

"""BORRO EL NODO CUANDO TERMINA EL SONIDO DE ATAQUE"""
func _on_finished() -> void:
	queue_free()
