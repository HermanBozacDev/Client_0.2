extends Area2D

"""INIT Y BORRAR NODO"""
func _ready() -> void:
	await(get_tree().create_timer(1).timeout)
	queue_free()
