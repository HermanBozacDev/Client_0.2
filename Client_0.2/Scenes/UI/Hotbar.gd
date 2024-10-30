extends Control



func _ready():
	for i in range(1,10):
		
		var slot_new = load("res://Scenes/UI/MultiSlot.tscn").instantiate()
		slot_new.set_name(str(i))
		slot_new.group = "hotbar"
		slot_new.type = "hotbar"
		slot_new.hotbar_id = str(i)
		slot_new.get_node("texture").set_shortcut(load("res://Scenes/UI/Shortcut_" + str(i) + ".tres"))
		if PlayerData.hot_bar_dic.keys().has(str(i)):
			slot_new.id = PlayerData.hot_bar_dic[str(i)][0]
		get_node("Panel/HBoxContainer").add_child(slot_new)


func _on_delete_hotbar_slot_pressed() -> void:
	PlayerData.DeleteHotbarSlot = true
