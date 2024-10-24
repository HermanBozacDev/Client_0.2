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
	print("aca iporta ")
	if PlayerData.hot_bar_dic.keys().has(get_name()):
		id = PlayerData.hot_bar_dic[get_name()][0]
		print("aca iporta ",id)
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
			#print("item?")
			pass



"""INTERACCION CON SLOT """

func _on_texture_pressed() -> void:
	PlayerData.key_group = group
	ClearOldMenus()
	for slot in get_tree().get_nodes_in_group("MultiSlot"):
		slot.get_node("SelectBackground").hide()
	
	if PlayerData.selected == true and PlayerData.move_item == false :
		
		if group == "hotbar":
			print("SOLO CUANDO SELECTED TRUE Y MOVE ITEM FALSE MATO LA ENTRADA DEL GHOTBAR")
			return
		
	print("texture pressed ",id)
	ClearOldMenus()
	if PlayerData.move_item:
		MoveItem()
	else:
		if group == "hotbar":
			if PlayerData.hot_bar_dic.has(get_name()):
				print("toque en un boton del hotbar especificamente sin banderas de accion")
				PlayerData.numero_boton_apretado = str(get_name())
				PlayerData.procesando_boton = true
				PlayerData.SetHotBarData(id,get_name(),hotbar_root_id)
				PlayerData.KeyHotBarStateMachine()
		else:
				#TOCO UN SLOT-NO HAY BANDERAS DE MENU
				if PlayerData.selected == true:
					print("SELECTED TRUE")
					#YA HABIA ALGO SELECCIONADO
					if get_name() == PlayerData.key_correlative:
						#TOQUE EL MISMO SLOT
						print("TOQUE EN EL MISMO SLOT")
						UnselectSameKey()
					else:

						print("TOQUE UN SLOT DIFERENTE") 
						#SLOT DIFERENTE
						if id == null:
							#SLOT DIFERENTE PERO VACIO
							SelectedTouchNotID()
						else:
							#SLOT DIFERENTE VALIDO
							SelectedTouchToNewID()
				#NO HAY NADA SELECCIONADO PREVIAMENTE
				else:
					print("SELECTED NOT TRUE")
					if id == null:
						#TOQUE UN SLOT SIN ID
						return
					#SELECCIONE UN SLOT NUEVO DESDDE CERO
					SelectNewItemID()


func ClearAllSelectedStates():
	PlayerData.selected = false
	PlayerData.key_id = null
	PlayerData.key_type = null
	PlayerData.key_correlative = null
	PlayerData.move_item = false
	PlayerData.key_group = null

func UnselectSameKey():
	print("TOQUE EL MISMO BOTON SELECCIONADO ")
	PlayerData.selected = false
	PlayerData.key_id = null
	PlayerData.key_type = null
	PlayerData.key_correlative = null
	PlayerData.key_group = null

func SelectedTouchNotID():
	print("TOQUE UN BOTON SIN ID ")
	if !PlayerData.key_correlative:
		print("no hay key anterior seleccionada")
		print("aver el id cuando toco aca",id)
	else:
		PlayerData.selected = false
		PlayerData.key_id = null
		PlayerData.key_type = null
		PlayerData.key_correlative = null
		PlayerData.key_group = null


func SelectedTouchToNewID():
	print("TOQUE UN BOTON CON ID  DIFERENTE AL SELECCIONADO")
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
	print("SELECCIONE UN SLOT DEL INV O DE SKILLS")
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
	match PlayerData.key_group:
		"inventory":
			print("MOVIENDO AL INVENTARIO ",id)
			var path_to_last_select = PlayerData.key_correlative
			get_parent().get_node(str(path_to_last_select) + "/texture").set_texture_normal(null)
			get_parent().get_node(str(path_to_last_select)).id = null
			get_parent().get_node(str(path_to_last_select)).group = null
			PlayerData.key_to_move = get_name()
			var new_key = PlayerData.key_id
			id = new_key
			var key_reference = PlayerData.key_correlative
			PlayerData.inventory_dic.erase(key_reference)
			PlayerData.inventory_dic[get_name()] = [new_key]
			var key = "Inventory"
			GameServer.ClientSendDataToServer(key,PlayerData.inventory_dic)
			PlayerData.move_item = false
		"hotbar":
			print("MOVIENDO AL HOTBAR ",PlayerData.key_id)
			var relative_key = PlayerData.key_correlative
			var path_to_node = "/root/SceneHandler/CanvasLayer/MultiPanel/Panel/Background/Inventory/Inventory/Items/"
			var path_to_last_select = path_to_node + str(relative_key)
			get_parent().get_node(str(path_to_last_select) + "/texture").set_texture_normal(null)
			print("data",PlayerData.key_id,PlayerData.key_correlative)
			id = PlayerData.key_id
			hotbar_root_id = PlayerData.key_correlative
			PlayerData.hot_bar_dic[get_name()] = [id]
			PlayerData.hot_bar_dic[get_name()].append(hotbar_root_id)
			var key = "Hotbar"
			GameServer.ClientSendDataToServer(key,PlayerData.hot_bar_dic)
			#limpio el slot en el inventario
			get_node(path_to_node + relative_key).id = null
			get_node(path_to_node + relative_key).group = null
			get_node(path_to_node + relative_key+ "/texture").set_texture_normal(null)
			#limpio el global events
			PlayerData.key_id = null
			PlayerData.key_type = null
			PlayerData.key_correlative = null
			PlayerData.move_item = false
			PlayerData.selected = false
		"skills":
			print("skill")
			ClearAllSelectedStates()
			return
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
	for menu in get_tree().get_nodes_in_group("Menu"):
		var node_name = menu.name
		get_node("/root/SceneHandler/CanvasLayer/" + str(node_name)).queue_free()
