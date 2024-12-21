extends Node

"""PLAYER DATA VARIABLES"""
var player_name
var player_map = "CiudadPrincipal"
var player_class
var player_type
var player_load = false
var is_respawning = false
var delete_player = false
"""DICCIONARIOS"""
var stats_dic = {}
var inventory_dic = {}
var equip_item_dic = {}
var hot_bar_dic = {}
var learn_skill_dic = {}
"""HOTBAR FUNCIONES"""
var raiz_inventario_hotbar
var id_boton_apretado
var skill_instance
"""VARIABLES PARA USO DE LA INTERFAZ DE USUARIO"""
var key_correlative
var key_id
var key_type
var key_group
var key_to_move
var last_multi_panel
var numero_boton_apretado
var move_item = false
var move_skill = false
var selected = false
var procesando_boton = false
var DeleteHotbarSlot = false
var hotbar = preload("res://Scenes/UI/Hotbar.tscn")#a esta mierda me confunde con el nombre despues lo cambio
var player_view = preload("res://Scenes/UI/PlayerView.tscn")
var player_options = preload("res://Scenes/UI/PanelOptions.tscn")
var client_player_scene = load("res://Scenes/Player/player.tscn")


"""DIFERENTES TIPOS DE SPAWN CLIENTE"""
func SpawnClientPlayer(key,value):
	match key:
		"NewPlayerRegister":
			NewPlayerRegister(value)
		"LoadPlayer":
			LoadPlayer(value)
		"Teleport":
			Teleport(value)
		"PlayerDie":
			KillingPlayer(value)

"""SPAWN NEUVO PLAYER"""
func NewPlayerRegister(value):
	stats_dic = value[0]
	learn_skill_dic = value[4]
	player_name = value[5]
	player_map = value[0]["M"]
	player_type = value[0]["Type"]
	player_class = value[0]["Class"]
	inventory_dic = value[1]
	var client_player_instance = client_player_scene.instantiate()
	get_node("/root/SceneHandler").SetMap(client_player_instance,"CiudadPrincipal")
	get_parent().get_node("SceneHandler/LoginScreen").hide()
	get_parent().get_node("SceneHandler/" + "CiudadPrincipal" +  "/MapElements/Player").set_physics_process(true)
	CanvasItems()
"""SPAWN LOAD PLAYER"""
func LoadPlayer(value):
	stats_dic = value[0]
	learn_skill_dic = value[4]
	player_name = value[5]
	player_map = value[0]["M"]
	player_type = value[0]["Type"]
	player_class = value[0]["Class"]
	inventory_dic = value[1]
	hot_bar_dic = value[2]
	equip_item_dic = value[3]
	var client_player_instance = client_player_scene.instantiate()
	get_node("/root/SceneHandler").SetMap(client_player_instance,value[0]["M"])
	get_parent().get_node("SceneHandler/LoginScreen").hide()
	get_parent().get_node("SceneHandler/" + value[0]["M"] +  "/MapElements/Player").set_physics_process(true)
	CanvasItems()
"""SPAWN TELEPORT"""
func Teleport(value):
	var client_player_instance = client_player_scene.instantiate()
	get_node("/root/SceneHandler/" + value[0]).queue_free()
	client_player_instance.position = value[3]
	PlayerData.player_map = value[1]
	for player in get_tree().get_nodes_in_group("Map"):
		player.queue_free()
	get_node("/root/SceneHandler").SetMap(client_player_instance,value[1])
	get_node("/root/SceneHandler/" + value[1] +  "/MapElements/Player").set_physics_process(true)
"""SPAWN AFTER DEAD"""
func KillingPlayer(value):
	if is_respawning:
		return  
	get_node("/root/SceneHandler/DeadWindows").show()
	is_respawning = true
	get_node("/root/SceneHandler/" + value  +"/MapElements/Player").queue_free()
	player_load = true
	stats_dic["M"] = "CiudadPrincipal"
	stats_dic["Px"] = 0
	stats_dic["Py"] = 0
	var client_player_instance = client_player_scene.instantiate()
	get_node("../SceneHandler").SetMapThenDie(client_player_instance, "CiudadPrincipal")
	await get_tree().create_timer(1).timeout
	get_node("/root/SceneHandler/DeadWindows").hide()
	get_node("/root/SceneHandler/"+ stats_dic["M"] +"/MapElements/Player").position = Vector2(0,0)
	is_respawning = false




#funcion info donde envio info dinamica para buscar primero matcheo el diccionario y despues me fijo 
#tipo "nombre del item/skill" "ejemplo. "SkillType","ItemDescrition"
#llmar a client send info to servery generara en el servidor la estructura para el return con la data
"""PARA EL PLAYER VIEW"""
"""TODO ESTO LO TENGO QUE REEMPLAZAR CON UNA SOLA FUNCION GETVALUE"""

func GetValue(value):
	return stats_dic[value]

"""ESTO MANEJA LOS ITEMS CANVAS DEL PLAYER"""
func CanvasItems():
	var hotbar_instance = hotbar.instantiate()
	get_node("/root/SceneHandler/CanvasLayer").add_child(hotbar_instance)
	var player_view_instance = player_view.instantiate()
	get_node("/root/SceneHandler/CanvasLayer").add_child(player_view_instance)
	var player_options_instance = player_options.instantiate()
	get_node("/root/SceneHandler/CanvasLayer").add_child(player_options_instance)

"""MANDAR NUEVO INVENTARIO AL SERVIDOR"""
func SendNewInventory():
	var key = "Inventory"
	GameServer.ClientSendDataToServer(key,inventory_dic)

"""FUNCION PARA EQUIPAR UN ITEM """
func EquipItem(value):
	#value = ["Item",PlayerData.key_id,informacion_requerida,"EquipItem"]
	#aca tendria que hacer verificiaciones de si los item son del nivel correcto y la clase correcta tambien
	PlayerData.equip_item_dic[value[0]] = PlayerData.key_id 
	var key = "EquipItems"
	GameServer.ClientSendDataToServer(key,PlayerData.equip_item_dic)
	PlayerData.inventory_dic.erase(PlayerData.key_correlative)
	get_tree().get_nodes_in_group("InventoryGrid")[0].get_node(str(PlayerData.key_correlative)).id = null
	get_tree().get_nodes_in_group("InventoryGrid")[0].get_node(str(PlayerData.key_correlative)).get_node("texture").set_texture_normal(null)
	for slot in get_tree().get_nodes_in_group("MultiSlot"):
		slot.get_node("SelectBackground").hide()
	PlayerData.key_correlative = null
	PlayerData.key_type = null
	PlayerData.key_id = null
	PlayerData.key_group = null
	PlayerData.selected = false
	
	
	key = "Inventory"
	GameServer.ClientSendDataToServer(key,PlayerData.inventory_dic)

"""CUANDO APRETO UNBOTON DEL HOTBAR SETEO DATA ACA PARA PROCESARLA"""
func SetHotBarData(id,number,hotbar_root):
	numero_boton_apretado = number
	id_boton_apretado = id
	raiz_inventario_hotbar = hotbar_root

"""PROCESANDO EL BOTON APRETADO"""
func KeyHotBarStateMachine():
	if learn_skill_dic.has(id_boton_apretado):
		"""MANA VERIFICACION """
		Match_Skill()
	else:
		"""ES UN ITEM"""
		match PlayerData.hot_bar_dic[PlayerData.numero_boton_apretado][1]:
			"Weapon":
				pass
			"Armor":
				pass
			"Consumables":
				pass
			"Others":
				pass

"""VERIFICACION DE SKILLS"""
func Match_Skill():
	match PlayerData.stats_dic["Type"]:
		"fighter":
			PlayerData.procesando_boton = false
			match PlayerData.learn_skill_dic[id_boton_apretado][2]:
				"TargetBuffDebuff":
					TargetBuffDebuffSkill()
				"MeleeSingleTargetSkill":
					MeleeSingleTargetSkill()
		"wizard":
			#get_tree().get_nodes_in_group("Jugador")[0].state = get_tree().get_nodes_in_group("Jugador")[0].CAST
			PlayerData.procesando_boton = false
			match PlayerData.learn_skill_dic[id_boton_apretado][2]:

				"RangedSingleTargetSkill":
					RangedSingleTargetSkill()
				"TargetBuffDebuff":
					TargetBuffDebuffSkill()
				"RangedAOESkill":
					pass
				"Nova":
					pass
				"SelfTargetSkill":
					pass

"""CREAR ATAQUES EN EL MAPA(ANTES DE CREAR LOS ATAQUES DEFINITIVAMENTE. DEBERIA IR AL SERVIDOR Y CONFIRMAR SI TIENE MANA ETC)"""
func MeleeBasicAttack():
	var player_node = get_tree().get_nodes_in_group("Jugador")[0]
	var skill = preload("res://Scenes/Skills/FisicAttack.tscn")
	var skill_instance = skill.instantiate()
	
	player_node.set_variables()
	player_node.destination = player_node.position
	var a_rotation = player_node.angle_to_mouse_position
	player_node.get_node("TurnAxis").rotation = a_rotation
	skill_instance.rotation = a_rotation
	
	var a_position =  (player_node.get_node("TurnAxis/Position2D").get_global_position()-player_node.get_global_position())
	skill_instance.position = a_position
	
	player_node.add_child(skill_instance)
	player_node.animation_vector = player_node.position.direction_to(player_node.get_global_mouse_position()).normalized()   
	player_node.animation_tree.set("parameters/Attack/blend_position", player_node.animation_vector)
	player_node.animation_mode.travel("Attack")
	
	var value = ["FisicAttack","BasicAttack",a_rotation,a_position, player_node.animation_vector, GameServer.client_clock,PlayerData.player_map,player_node.get_node("TurnAxis/Position2D").get_global_position()]
	var key = "PlayerAttack"
	GameServer.ClientSendDataToServer(key, value)
			
			
func MeleeSingleTargetSkill():
	var skill = preload("res://Scenes/Skills/MeleeSingleTargetSkill.tscn")
	var new_skill_instance = skill.instantiate()
	var player_node = get_tree().get_nodes_in_group("Jugador")[0]
	player_node.set_variables()
	var a_rotation = player_node.angle_to_mouse_position
	player_node.get_node("TurnAxis").rotation = a_rotation
	new_skill_instance.rotation = a_rotation
	var a_position = player_node.get_node("TurnAxis/Position2D").get_global_position()-player_node.get_global_position()
	new_skill_instance.position = a_position
	var animation_vector = player_node.position.direction_to(player_node.get_global_mouse_position()).normalized()   
	var attack_type = PlayerData.learn_skill_dic[id_boton_apretado][2]
	var value = [attack_type,id_boton_apretado,a_rotation, player_node.get_node("TurnAxis/Position2D").get_global_position(), PlayerData.player_map,player_node.position,animation_vector, GameServer.client_clock]
	var key = "PlayerAttack"
	GameServer.ClientSendDataToServer(key, value)
	
	player_node.add_child(new_skill_instance)
func RangedSingleTargetSkill():
	var skill = preload("res://Scenes/Skills/SingleTargetRangedSkill.tscn")
	skill_instance = skill.instantiate()
	var hit_effect = load("res://Scenes/Skills/CastFx.tscn").instantiate()
	get_tree().get_nodes_in_group("Jugador")[0].get_node("Auras").add_child(hit_effect)
	var player_node = get_tree().get_nodes_in_group("Jugador")[0]
	player_node.set_variables()
	player_node.get_node("TurnAxis").rotation = player_node.angle_to_mouse_position
	var a_rotation = player_node.get_node("TurnAxis").rotation
	skill_instance.rotation = a_rotation
	var a_position = player_node.get_node("TurnAxis/Position2D").get_global_position()
	skill_instance.position = a_position
	skill_instance.projectile_speed = PlayerData.learn_skill_dic[id_boton_apretado][3]
	skill_instance.skill_name = id_boton_apretado
	var attack_type = PlayerData.learn_skill_dic[id_boton_apretado][2]
	player_node.moving = false
	var a_direction = player_node.direction
	player_node.animation_vector = player_node.position.direction_to(player_node.get_global_mouse_position()).normalized()   
	var value = [attack_type,id_boton_apretado, a_rotation, a_position, a_direction, PlayerData.player_map, player_node.position, player_node.animation_vector, GameServer.client_clock ]
	var key = "PlayerAttack"
	GameServer.ClientSendDataToServer(key, value)
	get_parent().add_child(skill_instance)
func TargetBuffDebuffSkill():
	var skill = preload("res://Scenes/Skills/TargetBuffDebuff.tscn")
	var player_node = get_tree().get_nodes_in_group("Jugador")[0]
	skill_instance = skill.instantiate()
	skill_instance.position = player_node.get_global_mouse_position() - player_node.position
	var attack_type = PlayerData.learn_skill_dic[id_boton_apretado][2]
	var value = [attack_type,id_boton_apretado, player_node.get_global_mouse_position(), PlayerData.player_map, player_node.position, GameServer.client_clock ]
	var key = "PlayerAttack"
	GameServer.ClientSendDataToServer(key, value)
	player_node.add_child(skill_instance)
