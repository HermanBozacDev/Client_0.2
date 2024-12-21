extends Control
var result
var text
@onready var alert_text = $Panel/Body/Label

"""INIT"""
func _ready() -> void:
	alert_text.set_text(text)

"""BORRO EL NODO AL PRESS OK"""


func _on_yes_pressed() -> void:
	PlayerData.delete_player = true
	


func _on_no_pressed() -> void:
	PlayerData.delete_player = false
