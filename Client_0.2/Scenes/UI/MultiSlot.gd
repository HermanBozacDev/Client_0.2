extends Control

var id
var group

@export var type: String
@export var subType: String

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
	#cuando tengo el inventario abierto mientras amto me da un error Invalid operands 'String' and 'Nil' in operator '+'.
	if PlayerData.inventory_dic.keys().has(get_name()):
		var icon = load("res://Resources/Items/" + id + ".png")
		get_node("texture").set_texture_normal(icon)
func EquipLoad():
	match subType:
		"Hats":
			if PlayerData.equip_item_dic.has("Hats"):
				id = PlayerData.equip_item_dic["Hats"]
				var icon = load("res://Resources/Items/" + id + ".png")
				get_node("texture").set_texture_normal(icon)
		"Gloves":
			if PlayerData.equip_item_dic.has("Gloves"):
				id = PlayerData.equip_item_dic["Gloves"]
				var icon = load("res://Resources/Items/" + id + ".png")
				get_node("texture").set_texture_normal(icon)
			
		"Weapons":
			if PlayerData.equip_item_dic.has("Weapons"):
				id = PlayerData.equip_item_dic["Weapons"]
				var icon = load("res://Resources/Items/" + id + ".png")
				get_node("texture").set_texture_normal(icon)
			
		"Wings":
			if PlayerData.equip_item_dic.has("Wings"):
				id = PlayerData.equip_item_dic["Wings"]
				var icon = load("res://Resources/Items/" + id + ".png")
				get_node("texture").set_texture_normal(icon)
			
		"Armors":
			if PlayerData.equip_item_dic.has("Armors"):
				id = PlayerData.equip_item_dic["Armors"]
				var icon = load("res://Resources/Items/" + id + ".png")
				get_node("texture").set_texture_normal(icon)
			
		"Boots":
			if PlayerData.equip_item_dic.has("Boots"):
				id = PlayerData.equip_item_dic["Boots"]
				var icon = load("res://Resources/Items/" + id + ".png")
				get_node("texture").set_texture_normal(icon)
		"Shields":
			if PlayerData.equip_item_dic.has("Shields"):
				id = PlayerData.equip_item_dic["Shields"]
				var icon = load("res://Resources/Items/" + id + ".png")
				get_node("texture").set_texture_normal(icon)
func HotbarLoad():

	if PlayerData.hot_bar_dic.keys().has(get_name()):
		id = PlayerData.hot_bar_dic[get_name()][0]
		if PlayerData.learn_skill_dic.has(id):
			var icon = load("res://Resources/Skills/Icons/" + id + "_icon.png")
			get_node("texture").set_texture_normal(icon)
			type = "skill"
		else:
			var icon = load("res://Resources/Items/" + id + ".png")
			get_node("texture").set_texture_normal(icon)

"""INTERACCION CON SLOT """
func _on_texture_pressed() -> void:
	print("id ",id)
	PlayerData.key_group = group
	for slot in get_tree().get_nodes_in_group("MultiSlot"):
		slot.get_node("SelectBackground").hide()
	if PlayerData.move_item:
		if !PlayerData.selected:
			PlayerData.move_item= false
			return
		MoveItem()
	elif PlayerData.move_skill:
		if !PlayerData.selected:
			PlayerData.move_skill = false
			return
		MoveSkill()
	elif PlayerData.DeleteHotbarSlot:
		DeleteHotbarSlot()
	else:
		if group == "hotbar":
			if PlayerData.hot_bar_dic.has(get_name()):
				PlayerData.key_correlative = null
				PlayerData.key_type = null
				PlayerData.key_id = null
				PlayerData.selected = false
				#apagar stats primero
				PlayerData.numero_boton_apretado = get_name()
				PlayerData.procesando_boton = true
				PlayerData.SetHotBarData(id,get_name(),hotbar_root_id)
				PlayerData.KeyHotBarStateMachine()
			else:
				PlayerData.key_correlative = null
				PlayerData.key_type = null
				PlayerData.key_id = null
				PlayerData.selected = false
		else:#PUEDE VENIR SKILL O ITEM ACA
			if PlayerData.selected == true:
				print("YA HAY ALGO SELECCIONADO ANTERIORMENTE - ")
				if get_name() == PlayerData.key_correlative:
					print("VOLVI A TOCAR EL MISMO BOTON ASIQUE DESACTIVO ")
					DeseleccionarSlotSeleccionado()
				else:
					if id == null:
						print("TOQUE EN UN SLOT SIN ID ")
						DeseleccionarSlotSeleccionado()
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

"""DESCELECCION"""
func DeseleccionarSlotSeleccionado():
	PlayerData.selected = false
	PlayerData.key_id = null
	PlayerData.key_type = null
	PlayerData.key_correlative = null

"""NUEVO SLOT"""
func SeleccionarNuevoSlot():
	if PlayerData.key_type == "hotbar":
		PlayerData.key_correlative = null
		PlayerData.key_id = null
		PlayerData.key_type = null
		PlayerData.selected = false
	#actualizaciones visuales
	$SelectBackground.show()
	#seteo en player data
	PlayerData.selected = true
	PlayerData.key_id = id
	PlayerData.key_type = type
	PlayerData.key_correlative = str(get_name())

"""BORRAR SLOT DEL HOTBAR"""
func DeleteHotbarSlot():
	PlayerData.hot_bar_dic.erase(get_name())
	var key = "Hotbar"
	GameServer.ClientSendDataToServer(key,PlayerData.hot_bar_dic)
	$texture.set_texture_normal(null)
	PlayerData.DeleteHotbarSlot = false
	get_tree().get_nodes_in_group("Hotbar")[0].get_node("Panel/DeleteHotbarSlot").button_pressed = false

"""ACCIONES DEL MENU"""
func MoveSkill():
	if PlayerData.key_group == "hotbar":
		id = PlayerData.key_id
		hotbar_root_id = PlayerData.key_correlative
		PlayerData.hot_bar_dic[get_name()] = [id]
		PlayerData.hot_bar_dic[get_name()].append(hotbar_root_id)
		var key = "Hotbar"
		GameServer.ClientSendDataToServer(key,PlayerData.hot_bar_dic)
		PlayerData.key_id = null
		PlayerData.key_type = null
		PlayerData.key_correlative = null
		PlayerData.move_skill = false
		PlayerData.selected = false
	elif PlayerData.key_group == "skills":
		PlayerData.key_correlative = null
		PlayerData.key_id = null
		PlayerData.key_type = null
		PlayerData.move_skill = false
		PlayerData.selected = false

func MoveItem():
	#CUANDO MUEVO UN ITEM POR EL INVENTARIO PODRIA FIJARME SI ESTA EN EL HOTBAR Y ACTUALIZAR EL NUMERO DE REFERENCIA TAMBIEN.
	match PlayerData.key_group:
		"inventory":
			var new_key = PlayerData.key_id
			var key_reference = PlayerData.key_correlative
			var key = "Inventory"
			#slot al que voy puede ser vacio u ocupado
			if id == null:
				get_parent().get_node(str(PlayerData.key_correlative) + "/texture").set_texture_normal(null)
				get_parent().get_node(str(PlayerData.key_correlative)).id = null
				id = new_key
				var aux = PlayerData.inventory_dic[PlayerData.key_correlative]
				PlayerData.key_to_move = get_name()
				PlayerData.inventory_dic.erase(key_reference)
				PlayerData.inventory_dic[get_name()] = aux
				GameServer.ClientSendDataToServer(key,PlayerData.inventory_dic)
			else:
				var aux_destino = PlayerData.inventory_dic[get_name()]
				var aux_origen = PlayerData.inventory_dic[PlayerData.key_correlative]
				PlayerData.inventory_dic[get_name()] = aux_origen
				get_parent().get_node(PlayerData.key_correlative).id = aux_destino[0]
				
				#get_parent().get_node(str(path_to_last_select) + "/texture").set_texture_normal(aux_img_destino)
				PlayerData.inventory_dic[PlayerData.key_correlative] = aux_destino
				#get_node("texture").set_texture_normal(aux_img_origen)
				id = aux_origen[0]
				GameServer.ClientSendDataToServer(key,PlayerData.inventory_dic)
				#PlayerData.key_id = Bone_Boots
				#PlayerData.key_correlative = str(12)
				#move item esta on y selected esta on
				

			PlayerData.key_id = null
			PlayerData.key_type = null
			PlayerData.key_correlative = null
			PlayerData.move_item = false
			PlayerData.selected = false


			
	










		"hotbar":
			id = PlayerData.key_id
			hotbar_root_id = PlayerData.key_correlative
			PlayerData.hot_bar_dic[get_name()] = [id]
			var item = PlayerData.inventory_dic[hotbar_root_id]
			if item.size() > 2:
				PlayerData.hot_bar_dic[get_name()].append(item[2])
			else:
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


"""TIMER QUE REINICIA LA VISUAL VOY A VER SI ES NECESARIO"""
func _on_timer_timeout() -> void:
	_ready()
