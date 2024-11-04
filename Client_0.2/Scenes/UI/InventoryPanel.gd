extends Control

var grid = "TextureRect/Inventory/Grid"

"""INIT """
func _ready() -> void:
	for i in range(1,36):
		var slot_new = load("res://Scenes/UI/MultiSlot.tscn").instantiate()
		slot_new.set_name(str(i))
		slot_new.type = "inventory"
		slot_new.group = "inventory"
		if PlayerData.inventory_dic.keys().has(str(i)):
			slot_new.id = PlayerData.inventory_dic[str(i)][0]
			#slot_new.group = PlayerData.item_dic[slot_new.id].ItemSlotGroup
		get_node(grid).add_child(slot_new)

"""ACTIVAR FUNCION MOVE"""
func _on_move_pressed() -> void:
	PlayerData.move_item = true

"""ACTIVAR FUNCION EQUIP"""
func _on_equip_pressed() -> void:
	var key = "Information"
	var informacion_requerida = "ItemSlotGroup"
	var value = ["Item",PlayerData.key_id,informacion_requerida,"EquipItem"]
	GameServer.ClientSendDataToServer(key, value)
