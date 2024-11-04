extends Control

var text
@onready var alert_text = $Panel/Body/Label

"""INIT"""
func _ready() -> void:
	alert_text.set_text(text)

"""BORRO EL NODO AL PRESS OK"""
func _on_ok_pressed() -> void:
	queue_free()
