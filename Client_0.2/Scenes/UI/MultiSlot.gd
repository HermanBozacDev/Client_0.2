extends Control

var id
var type
var group
 

var hotbar_id
var hotbar_root_id

var skill_type


"""CARGA INICIAL DE IMAGENES POR ID """
func _ready():
	$Timer.start()
	match type:
		"equip":
			EquipLoad()
		"inventory":
			InventoryLoad()
		"hotbar":
			HotbarLoad()
		"skills":
			SkillsLoad()

func SkillsLoad():
	var icon = load("res://Resources/Skills/Icons/" + id + "_icon.png")
	get_node("texture").set_texture_normal(icon)

func InventoryLoad():
	if PlayerData.inventory_dic.keys().has(get_name()):
		var icon = load("res://Resources/Items/" + id + ".png")
		get_node("texture").set_texture_normal(icon)

func EquipLoad():
	if PlayerData.equip_item_dic.has(get_name()):
		id = PlayerData.equip_item_dic[get_name()][0]
		var icon = load("res://Resources/Items/" + id + ".png")
		get_node("texture").set_texture_normal(icon)
	var new_key = PlayerData.key_id
	var key_reference = PlayerData.key_correlative
	if new_key != null:
		PlayerData.inventory_dic.erase(key_reference)
		var new_reference = PlayerData.key_to_move
		PlayerData.inventory_dic[new_reference] = [new_key]
		#PlayerData.SendNewInventory()

func HotbarLoad():
	
	if PlayerData.hot_bar_dic.keys().has(get_name()):
		id = PlayerData.hot_bar_dic[get_name()][0]
		print(PlayerData.learn_skill_dic)
		if PlayerData.learn_skill_dic.has(id):
			var icon = load("res://Resources/Skills/Icons/" + id + "_icon.png")
			get_node("texture").set_texture_normal(icon)
			type = "skill"
			var active_skill_path = "/root/SceneHandler/CanvasLayer/MultiPanel/Panel/InventoryBackground/Skills/Body/ActiveSkills/HBoxContainer/ActiveSkillsContainer/"
			var pasive_skill_path = "/root/SceneHandler/CanvasLayer/MultiPanel/Panel/InventoryBackground/Skills/Body/PasiveSkills/HBoxContainer2/PasiveSkillsContainer/"
			if PlayerData.key_correlative:
				print("hay algo selecionado de antes")
				var skill_type = PlayerData.skill_dic[id]["SkillActivePasive"]
				match skill_type:
					"a":
						print("active skill")
						get_node(active_skill_path)
						#get_node(items_container_path + "ActiveSkills/HBoxContainer/ActiveSkillsContainer/"  + "/SelectBackground").hide()
					"p":
						print("pasive skill")
						get_node(pasive_skill_path)
						#get_node(items_container_path +  + "/SelectBackground").hide()
						
				#get_node(items_container_path +  + "/SelectBackground").hide()

			else:
				pass
				

				
			
			
		else:
			print("item?")



"""INTERACCION CON SLOT """

func _on_texture_pressed() -> void:
	print("si")
	print(hotbar_id,"  ",hotbar_root_id)
	ClearOldMenus()
	if PlayerData.move_item:
		print("osea")
		MoveItem()
	else:
		if group == "hotbar":
			print("interaccion viene del hotbar")
			if PlayerData.hot_bar_dic.has(get_name()):
				PlayerData.numero_boton_apretado = str(get_name())
				PlayerData.procesando_boton = true
				PlayerData.SetHotBarData(id,get_name(),hotbar_root_id)
				PlayerData.KeyHotBarStateMachine()

		elif type == "skills":
			print("esto que leo es un skill ")
			TouchSkill()
		else:

				#TOCO UN SLOT-NO HAY BANDERAS DE MENU
				if PlayerData.selected == true:
					#YA HABIA ALGO SELECCIONADO
					if get_name() == PlayerData.key_correlative:
						#TOQUE EL MISMO SLOT
						UnselectSameKey()
					else: 
						#SLOT DIFERENTE
						if id == null:
							#SLOT DIFERENTE PERO VACIO
							SelectedTouchNotID()
						#SLOT DIFERENTE VALIDO
						SelectedTouchToNewID()
				#NO HAY NADA SELECCIONADO PREVIAMENTE
				else:
					if id == null:
						#TOQUE UN SLOT SIN ID
						return
					#SELECCIONE UN SLOT NUEVO DESDDE CERO
					SelectNewItemID()

func UnselectSameKey():
	print("clicleo devuelta en el mismo boton ")
	$SelectBackground.hide()
	PlayerData.selected = false
	PlayerData.key_id = null
	PlayerData.key_type = null
	PlayerData.key_correlative = null

func SelectedTouchNotID():
	var path_to_last_select = PlayerData.key_correlative
	if !PlayerData.key_correlative:
		print("no hay key anterior seleccionada")
	else:
		get_parent().get_node(str(path_to_last_select) + "/SelectBackground").hide()
		PlayerData.selected = false
		PlayerData.key_id = null
		PlayerData.key_type = null
		PlayerData.key_correlative = null
		return

func TouchSkill():
	print("get_name in skill touch",get_name())
	$SelectBackground.show()
	PlayerData.selected = true
	PlayerData.key_id = id
	PlayerData.key_type = type
	PlayerData.key_correlative = get_name()
	print("key correlative",PlayerData.key_correlative,)
	var menu = load("res://Scenes/UI/Menu.tscn").instantiate()
	menu.position = Vector2(60,100)
	menu.mode = type
	get_node("/root/SceneHandler/CanvasLayer").add_child(menu)

func SelectedTouchToNewID():
	print("clicjkeo en un boton diferente")
	print("ya hay un item seleccionado")
	#apague el select en el otro lado y lo prendo en  el nuevo
	var path_to_last_select = PlayerData.key_correlative
	if !PlayerData.key_correlative:
		print("no hay key anterior seleccionada")
	else:
		get_parent().get_node(str(path_to_last_select) + "/SelectBackground").hide()
		$SelectBackground.show()
		PlayerData.selected = true
		PlayerData.key_id = id
		PlayerData.key_type = type
		PlayerData.key_correlative = get_name()
		var menu = load("res://Scenes/UI/Menu.tscn").instantiate()
		menu.position = Vector2(60,100)
		menu.mode = type
		get_node("/root/SceneHandler/CanvasLayer").add_child(menu)

func SelectNewItemID():
	print("SELECCIONE ITEM DEL INVENTARIO")
	PlayerData.selected = true
	PlayerData.key_id = id
	PlayerData.key_type = type
	PlayerData.key_correlative = get_name()
	$SelectBackground.show()
	var menu = load("res://Scenes/UI/Menu.tscn").instantiate()
	menu.position = Vector2(60,100)
	menu.mode = type
	get_node("/root/SceneHandler/CanvasLayer").add_child(menu)




"""ACCIONES DEL MENU"""

func MoveItem():
	print("type",PlayerData.key_type)
	match PlayerData.key_type:
		"inventory":
			var path_to_last_select = PlayerData.key_correlative
			
			get_parent().get_node(str(path_to_last_select) + "/texture").set_texture_normal(null)
			get_parent().get_node(str(path_to_last_select) + "/SelectBackground").hide()
			get_parent().get_node(str(path_to_last_select)).id = null
			get_parent().get_node(str(path_to_last_select)).group = null
			PlayerData.key_to_move = get_name()
			var new_key = PlayerData.key_id
			id = new_key
			var key_reference = PlayerData.key_correlative
			PlayerData.inventory_dic.erase(key_reference)
			PlayerData.inventory_dic[get_name()] = [new_key]
			PlayerData.SendNewInventory()
			PlayerData.move_item = false
		"hotbar":
			var relative_key = PlayerData.key_correlative
			var path_to_node = "/root/SceneHandler/CanvasLayer/MultiPanel/Panel/InventoryBackground/Inventory/Inventory/Items/"
			print("nodo",get_node(path_to_node + relative_key) )
			#get_parent().get_node(str(path_to_last_select) + "/texture").set_texture_normal(null)
			print("hotbarkey destino para mover")
			print("data",PlayerData.key_id,PlayerData.key_correlative)
			id = PlayerData.key_id
			hotbar_root_id = PlayerData.key_correlative
			PlayerData.hot_bar_dic[get_name()] = [id]
			PlayerData.hot_bar_dic[get_name()].append(hotbar_root_id)
			PlayerData.SendNewHotBar()
			
			
			#limpio el slot en el inventario
			get_node(path_to_node + relative_key).id = null
			get_node(path_to_node + relative_key).group = null
			get_node(path_to_node + relative_key + "/SelectBackground").hide()
			get_node(path_to_node + relative_key+ "/texture").set_texture_normal(null)
			#limpio el global events
			PlayerData.key_id = null
			PlayerData.key_type = null
			PlayerData.key_correlative = null
			PlayerData.move_item = false
			PlayerData.selected = false
		"skills":
			print("aca entra=")
			id = PlayerData.key_id
			PlayerData.hot_bar_dic[get_name()] = [id]
			print("skils movidos, ",PlayerData.hot_bar_dic,PlayerData.learn_skill_dic)
			PlayerData.SendNewHotBar()
			print("id",id)
			#var _active_skill_path = "/root/SceneHandler/CanvasLayer/MultiPanel/Panel/InventoryBackground/Skills/Body/ActiveSkills/HBoxContainer/ActiveSkillsContainer/"
			#bueno aca borre cosas y aca tengo que limitar qpara que solo puedas seleecionar items activos que los pasivos no se puedan mover
			print("active skill")
			#get_node(active_skill_path + str(PlayerData.key_correlative) + "/SelectBackground").hide()

			
			PlayerData.key_id = null
			PlayerData.key_type = null
			PlayerData.key_correlative = null
			PlayerData.selected = false
			PlayerData.move_item = false
			


"""LIMPIEZA DE NODOS """

func ClearOldMenus():
	var actual_menu = get_tree().get_nodes_in_group("Menu")
	for menu in actual_menu:
		var node_name = menu.name
		get_node("/root/SceneHandler/CanvasLayer/" + str(node_name)).queue_free()
