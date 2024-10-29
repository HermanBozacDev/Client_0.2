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
	pass
func HotbarLoad():

	if PlayerData.hot_bar_dic.keys().has(get_name()):
		id = PlayerData.hot_bar_dic[get_name()][0]
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
			var icon = load("res://Resources/Items/" + id + ".png")
			get_node("texture").set_texture_normal(icon)
func ClearOldMenus():
	for menu in get_tree().get_nodes_in_group("Menu"):
		var node_name = menu.name
		get_node("/root/SceneHandler/CanvasLayer/" + str(node_name)).queue_free()
func InstanciarMenu(type):
	var menu = load("res://Scenes/UI/Menu.tscn").instantiate()
	#menu.position = Vector2(0,100)
	menu.mode = type
	get_node("/root/SceneHandler/CanvasLayer").add_child(menu)

"""INTERACCION CON SLOT """

func _on_texture_pressed() -> void:
	print("NOMBRE DEL NODO",get_name())
	print("LEARN SKILL DATA",PlayerData.learn_skill_dic)
	print("HOTBAR DATA",PlayerData.hot_bar_dic)
	print("INVENTORY DATA",PlayerData.inventory_dic)
	print("id ",id)
	print("group ",group)
	print("type ",type)
	print("hotbar_id ",hotbar_id)
	print("hotbar_root_id ",hotbar_root_id)
	print("key_correlative ",PlayerData.key_correlative)
	print("PlayerData.key_id ",PlayerData.key_id)
	print("PlayerData.key_type ",PlayerData.key_type)
	print("PlayerData.key_group ",PlayerData.key_group)
	print("PlayerData.key_to_move",PlayerData.key_to_move)
	print("PlayerData.last_multi_panel",PlayerData.last_multi_panel)
	print("PlayerData.last_multi_panel",PlayerData.last_multi_panel)
	print("PlayerData.move_item", PlayerData.move_item)
	print("PlayerData.numero_boton_apretado",PlayerData.numero_boton_apretado)
	print("PlayerData.selected",PlayerData.selected)
	print("PlayerData.procesando_boton",PlayerData.procesando_boton)
	

	PlayerData.key_group = group
	ClearOldMenus()
	for slot in get_tree().get_nodes_in_group("MultiSlot"):
		slot.get_node("SelectBackground").hide()
	if PlayerData.selected == true and PlayerData.move_item == false :
		
		if group == "hotbar":
			print("SOLO CUANDO SELECTED TRUE Y MOVE ITEM FALSE MATO LA ENTRADA DEL HOTBAR")
			return
	if PlayerData.move_item:
		MoveItem()
	else:
		if group == "hotbar":
			if PlayerData.hot_bar_dic.has(get_name()):
				print("BOTON DEL HOTBAR PROCESAR...")
				print("toque en un boton del hotbar especificamente sin banderas de accion")
				PlayerData.numero_boton_apretado = get_name()
				PlayerData.procesando_boton = true
				PlayerData.SetHotBarData(id,get_name(),hotbar_root_id)
				PlayerData.KeyHotBarStateMachine()
		else:#PUEDE VENIR SKILL O ITEM ACA
			if PlayerData.selected == true:
				print("YA HAY ALGO SELECCIONADO ANTERIORMENTE - ")
				if get_name() == PlayerData.key_correlative:
					print("VOLVI A TOCAR EL MISMO BOTON ASIQUE DESACTIVO ")
					DeseleccionarSlotSeleccionado()
				else:
					if id == null:
						print("TOQUE EN UN SLOT SIN ID ")
					else:
						print("TOQUE EN UN SLOT CON ID ")
						SeleccionarNuevoSlot()
			else:
				print("NO HAY NADA SELECCIONADO")
				if id == null:
					print("NO HAY ID PARA SELECCIONAR")
					return
				print(" SELECCIONAR NUEVO SLOT")
				SeleccionarNuevoSlot()



func DeseleccionarSlotSeleccionado():
	PlayerData.selected = false
	PlayerData.key_id = null
	PlayerData.key_type = null
	PlayerData.key_correlative = null

func SeleccionarNuevoSlot():
	#actualizaciones visuales
	InstanciarMenu(type)
	$SelectBackground.show()
	#seteo en player data
	PlayerData.selected = true
	PlayerData.key_id = id
	PlayerData.key_type = type
	PlayerData.key_correlative = str(get_name())








"""ACCIONES DEL MENU"""

func MoveItem():
	print("type",PlayerData.key_type)
	match PlayerData.key_group:
		"inventory":
			print("toque en el inventario")
			
		"hotbar":
			print("toque en el hotbar")
			id = PlayerData.key_id
			hotbar_root_id = PlayerData.key_correlative
			PlayerData.hot_bar_dic[get_name()] = [id]
			if PlayerData.key_type == "skills":
				print("es un skillsKKK")
			else:
				print("ahora si es un itemKKK",PlayerData.inventory_dic)
				var item = PlayerData.inventory_dic[hotbar_root_id]
				print("item", item )
				if item.size() > 2:
					print("es item con count")
					PlayerData.hot_bar_dic[get_name()].append(item[2])
				else:
					print("item sin count")
					PlayerData.hot_bar_dic[get_name()].append(item[1])
				#aca defino el value[1] de los item del hotbar
			PlayerData.hot_bar_dic[get_name()].append(hotbar_root_id)
			var key = "Hotbar"
			GameServer.ClientSendDataToServer(key,PlayerData.hot_bar_dic)
			PlayerData.key_id = null
			PlayerData.key_type = null
			PlayerData.key_correlative = null
			PlayerData.move_item = false
			PlayerData.selected = false



			
			
		"skills":
			pass
