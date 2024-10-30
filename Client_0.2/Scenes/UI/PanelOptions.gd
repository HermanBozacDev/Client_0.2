extends Control

@onready var canvas_node = get_node("/root/SceneHandler/CanvasLayer")
var open = false
var actual = null

func ClosePanel():
	for node in get_tree().get_nodes_in_group("Panel"):
		node.queue_free()
	#aprobecho a poner false los move aca
	PlayerData.move_item = false
	PlayerData.move_skill = false
	PlayerData.selected = false
	PlayerData.key_correlative = null
	PlayerData.key_id = null


func _on_inventory_pressed() -> void:
	if open == true and actual == "inventory":
		print("cerrar")
		ClosePanel()
		open = false
	else:
		actual = "inventory"
		open = true
		ClosePanel()
		var inventory = load("res://Scenes/UI/InventoryPanel.tscn").instantiate()
		canvas_node.add_child(inventory)
	


func _on_skills_pressed() -> void:
	if open == true and actual == "skills":
		print("cerrar")
		ClosePanel()
		open = false
	else:
		actual = "skills"
		open = true
		ClosePanel()
		var skills = load("res://Scenes/UI/SkillsPanel.tscn").instantiate()
		canvas_node.add_child(skills)

func _on_equip_pressed() -> void:
	if open == true and actual == "equip":
		print("cerrar")
		ClosePanel()
		open = false
	else:
		actual = "equip"
		open = true
		ClosePanel()
		var equip = load("res://Scenes/UI/EquipPanel.tscn").instantiate()
		canvas_node.add_child(equip)


func _on_stats_pressed() -> void:
	if open == true and actual == "stats":
		print("cerrar")
		ClosePanel()
		open = false
	else:
		actual = "stats"
		open = true
		ClosePanel()
		var stats = load("res://Scenes/UI/StatsPanel.tscn").instantiate()
		canvas_node.add_child(stats)

func _on_menu_pressed() -> void:
	if open == true and actual == "menu":
		print("cerrar")
		ClosePanel()
		open = false
	else:
		actual = "menu"
		open = true
		ClosePanel()
		var menu = load("res://Scenes/UI/MenuPanel.tscn").instantiate()
		canvas_node.add_child(menu)
