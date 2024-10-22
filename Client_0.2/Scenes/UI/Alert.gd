extends Control

var text
@onready var alert_text = $Panel/Body/Label

func _ready() -> void:
	alert_text.set_text(text)



func _on_ok_pressed() -> void:
	#var login_screen = get_tree().get_nodes_in_group("LoginScreen")[0]
	#login_screen.create_new_player_button.disabled = false
	queue_free()
