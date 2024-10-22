extends Control

var slot_name
var slot_level

@onready var character_name = $Panel/HBoxContainer/CharacterName
@onready var character_level= $Panel/HBoxContainer/CharacterLevel

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	character_name.set_text(slot_name)
	character_level.set_text(str(slot_level))

func _on_load_pressed() -> void:
	get_node("/root/SceneHandler/LoginScreen").OnLoadPressed(slot_name)



func _on_delete_pressed() -> void:
	get_node("/root/SceneHandler/LoginScreen").OnDeletePressed(slot_name)
