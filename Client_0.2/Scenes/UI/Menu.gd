extends Control


@onready var inventory_options = $Inventory
@onready var equip_options = $EquipedItems
var mode 

func _ready():
	match mode:
		"inventory":
			inventory_options.show()
			equip_options.hide()
		"equip":
			inventory_options.hide()
			equip_options.show()
		"skills":
			print("instancie un menu de skills")

func _on_use_pressed() -> void:
	print("APRETE USE VOY A INTENTAR USAR")

func _on_equip_pressed() -> void:
	print("APRETE EQUIP VOY A INTENTAR EQUIPAR")
	#PlayerData.hot_bar_dic[PlayerData.numero_boton_apretado][1]
	var new_key = PlayerData.key_id
	var key_reference = PlayerData.key_correlative
	if new_key != null:
		"""ES UN ITEM"""
		match PlayerData.inventory_dic[PlayerData.key_correlative][1]:
			"Weapon":
				print("WEAPON")
				var value = str(1)
				PlayerData.equip_item_dic[value] = [new_key]
				PlayerData.inventory_dic.erase(key_reference)
				var key = "Inventory"
				GameServer.ClientSendDataToServer(key,PlayerData.inventory_dic)
				key = "EquipItems"
				GameServer.ClientSendDataToServer(key,PlayerData.equip_item_dic)
			"Armor":
				print("INTENTO EQUIPAR ARMADURA")
				var value = str(1)
				PlayerData.equip_item_dic[value] = [new_key]
				PlayerData.inventory_dic.erase(key_reference)
				var key = "Inventory"
				GameServer.ClientSendDataToServer(key,PlayerData.inventory_dic)
				key = "EquipItems"
				GameServer.ClientSendDataToServer(key,PlayerData.equip_item_dic)

			"Consumables":
				pass
			"Others":
				pass





func _on_drop_pressed() -> void:
	print("APRETE DROP VOY A INTENTAR ELIMINAR")
	pass # Replace with function body.
