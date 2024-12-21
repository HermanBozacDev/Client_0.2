extends Control

var slot_name
var slot_level
var username

@onready var character_name = $Panel/HBoxContainer/CharacterName
@onready var character_level= $Panel/HBoxContainer/CharacterLevel

"""INIT"""
func _ready() -> void:
	character_name.set_text(slot_name)
	character_level.set_text(str(slot_level))

"""BOTON LOAD EN LOAD SLOT"""
func _on_load_pressed() -> void:
	var value = [slot_name,username]
	get_node("/root/SceneHandler/LoginScreen").OnLoadPressed(value)

"""BOTON DELETE EN LOAD SLOT TODAVIA NO ESTA APLICADO ESTO"""
func _on_delete_pressed() -> void:
	var value = [slot_name,username]
	get_node("/root/SceneHandler/LoginScreen").OnDeletePressed(value,self)
