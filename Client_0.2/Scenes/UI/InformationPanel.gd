extends Control
@onready var id = $TextureRect/VBoxContainer/ID
@onready var description = $TextureRect/VBoxContainer/Description
var descriptionText

func _ready() -> void:
	id.set_text(str(PlayerData.key_id))
	description.set_text(descriptionText)
	
