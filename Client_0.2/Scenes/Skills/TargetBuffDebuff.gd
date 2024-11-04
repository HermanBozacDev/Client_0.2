extends Node2D

var processing_body = false

"""INIT Y BORRAR NODO"""
func _ready() -> void:
	await (get_tree().create_timer(0.1).timeout)
	queue_free()
