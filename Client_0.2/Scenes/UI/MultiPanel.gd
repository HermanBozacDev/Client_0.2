extends Control
@onready var active_skills = $Panel/InventoryBackground/Skills/Body/ActiveSkills
@onready var pasive_skills = $Panel/InventoryBackground/Skills/Body/PasiveSkills

@onready var active_skills_container = $Panel/InventoryBackground/Skills/Body/ActiveSkills/HBoxContainer/ActiveSkillsContainer
@onready var pasive_skills_container = $Panel/InventoryBackground/Skills/Body/PasiveSkills/HBoxContainer2/PasiveSkillsContainer

@onready var inventory = $Panel/InventoryBackground/Inventory
@onready var skills = $Panel/InventoryBackground/Skills



var path_to_inventory_slots = "Panel/InventoryBackground/Inventory/Inventory/Items"
var path_to_equiped_slots = "Panel/InventoryBackground/Inventory/Inventory/EquipItems"
var path_to_extra_equiped_slots = "Panel/InventoryBackground/Inventory/Inventory/ExtraItems"
var diccionario_de_Grupos = {
	"1": "Weapons",
	"2": "Cascos",
	"3": "Armors",
	"4": "Guantes",
	"5": "Boots",
	"6": "Rings",
	"7": "Rings",
	"8": "Earrings",
	"9": "Earrings",
	"10": "Necklaces",
	"11": "Necklaces",
	"12": "Necklaces",
	"13": "Necklaces",
	"14": "Necklaces",
	"15": "Necklaces"
}

func _ready():
	_on_inventory_pressed()#siempre comienza en el inventario
	
	for i in range(1,26):
		var slot_new = load("res://Scenes/UI/MultiSlot.tscn").instantiate()
		slot_new.set_name(str(i))
		slot_new.type = "inventory"
		if PlayerData.inventory_dic.keys().has(str(i)):
			slot_new.id = PlayerData.inventory_dic[str(i)][0]
			#slot_new.group = PlayerData.item_dic[slot_new.id].ItemSlotGroup
		get_node(path_to_inventory_slots).add_child(slot_new)

	for i in range(1,16):
		var slot_new = load("res://Scenes/UI/MultiSlot.tscn").instantiate()
		slot_new.set_name(str(i))
		slot_new.type = "equip"
		get_node(path_to_equiped_slots).add_child(slot_new)


	for i in range(1,6):
		var slot_new = load("res://Scenes/UI/MultiSlot.tscn").instantiate()
		slot_new.set_name(str(i))
		slot_new.type = "equipextra"
		get_node(path_to_extra_equiped_slots).add_child(slot_new)

	match PlayerData.last_multi_panel:
		"skills":
			_on_skills_panel_pressed()
		"inventory":
			_on_inventory_pressed()
			
			



func _on_active_skill_button_pressed() -> void:
	active_skills.show()
	pasive_skills.hide()

func _on_pasive_skill_button_pressed() -> void:
	active_skills.hide()
	pasive_skills.show()

func _on_skills_panel_pressed() -> void:
	PlayerData.last_multi_panel = "skills"
	inventory.hide()
	skills.show()
	active_skills.show()
	pasive_skills.hide()

	# Eliminar los hijos actuales del contenedor de skills activos
	for child in active_skills_container.get_children():
		child.queue_free()

	# Eliminar los hijos actuales del contenedor de skills pasivos
	for child in pasive_skills_container.get_children():
		child.queue_free()

	var count = 1
	for skill in PlayerData.learn_skill_dic.values():
		var slot_new = load("res://Scenes/UI/MultiSlot.tscn").instantiate()
		slot_new.type = "skills"
		slot_new.id = skill[0]
		slot_new.set_name(str(count))
		slot_new.skill_type = skill[1]

		if skill[1] == "a":
			active_skills_container.add_child(slot_new)
		else:
			pasive_skills_container.add_child(slot_new)
		count += 1


func _on_inventory_pressed() -> void:
	PlayerData.last_multi_panel = "inventory"
	inventory.show()
	skills.hide()


func _on_exit_pressed() -> void:
	queue_free()
