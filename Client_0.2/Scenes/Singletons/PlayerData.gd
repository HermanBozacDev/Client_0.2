extends Node
"""VARIABLES PARA USO DE LA INTERFAZ DE USUARIO"""
var key_correlative
var key_id
var key_type
var key_to_move
var last_multi_panel
var move_item
var numero_boton_apretado
var selected = false
var procesando_boton = false
"""DICCIONARIOS"""
var stats_dic = {}
var inventory_dic = {}
var equip_item_dic = {}
var hot_bar_dic = {}
var learn_skill_dic = {}
"""NICKNAME"""
var player_name

var player_load = false




"""HOTBAR FUNCIONES"""
var raiz_inventario_hotbar
var id_boton_apretado
var skill_instance




func SendNewHotBar():
	var key = "Hotbar"
	GameServer.ClientSendDataToServer(key,hot_bar_dic)

func SendNewInventory():
	var key = "Inventory"
	GameServer.ClientSendDataToServer(key,inventory_dic)




func SetHotBarData(id,number,hotbar_root):
	numero_boton_apretado = number
	id_boton_apretado = id
	raiz_inventario_hotbar = hotbar_root

func KeyHotBarStateMachine():
	if learn_skill_dic.has(id_boton_apretado):
		"""ES UN SKILL"""
		"""MANA VERIFICACION """
		Match_Skill()
	else:
		"""ES UN ITEM"""
		match PlayerData.item_dic[id_boton_apretado].ItemType:
			"Weapon":
				print("Weapon")
			"Armor":
				print("Armor")
			"Consumables":
				print("Consumables")
			"Others":
				print("Others")





"""VERIFICACION DE SKILLS"""

func Match_Skill():
	match PlayerData.stats_dic["type"]:
		"fighter":
			PlayerData.procesando_boton = false
			match PlayerData.learn_skill_dic[id_boton_apretado][2]:
				"RangedSingleTargetSkill":
					RangedSingleTargetSkill()
		"wizard":
			print("soy wizard")
			#get_tree().get_nodes_in_group("Jugador")[0].state = get_tree().get_nodes_in_group("Jugador")[0].CAST
			PlayerData.procesando_boton = false
			match PlayerData.learn_skill_dic[id_boton_apretado].SkillType:
				"RangedSingleTargetSkill":
					RangedSingleTargetSkill()
				"RangedAOESkill":
					print("ahora tengo ranged aoe skill")
					pass
				"Nova":
					pass
				"SelfTargetSkill":
					print("pase")
					pass



func RangedSingleTargetSkill():
	print("ranged single PASEEEEE",id_boton_apretado)
	var skill = preload("res://Scenes/Skills/SingleTargetRangedSkill.tscn")
	skill_instance = skill.instantiate()
	match id_boton_apretado:
		"WindStrike":
			SpawnRangedSingleTargetSkill(skill_instance)


"""RANGED SINGLE TARGET """
func SpawnRangedSingleTargetSkill(skill_instance):
	#apply_coldown_in_hotbar()
	get_tree().get_nodes_in_group("Jugador")[0].set_variables()
	get_tree().get_nodes_in_group("Jugador")[0].get_node("TurnAxis").rotation = get_tree().get_nodes_in_group("Jugador")[0].angle_to_mouse_position
	skill_instance.rotation = get_tree().get_nodes_in_group("Jugador")[0].get_node("TurnAxis").rotation
	skill_instance.position = get_tree().get_nodes_in_group("Jugador")[0].get_node("TurnAxis/Position2D").get_global_position()
	skill_instance.projectile_speed = PlayerData.learn_skill_dic[id_boton_apretado][3]
	skill_instance.skill_name = id_boton_apretado
	var attack_type = PlayerData.learn_skill_dic[id_boton_apretado][2]
	get_tree().get_nodes_in_group("Jugador")[0].Attack(skill_instance.rotation,skill_instance.position,id_boton_apretado,skill_instance,attack_type)


""" LAST CONFIRMATIONS OF TYPE IN SPECIFIC OBJECTS """







func SpawnClientPlayer(value):
	#value = [stats[0],inventory[1],hotbar[2],equipitem[3],learnskill[4],nickname[5]
	stats_dic = value[0]
	inventory_dic = value[1]
	hot_bar_dic = value[2]
	equip_item_dic = value[3]
	learn_skill_dic = value[4]
	player_name = value[5]
	var client_player_scene = load("res://Scenes/Player/player.tscn")
	var client_player_instance = client_player_scene.instantiate()
	get_node("/root/SceneHandler").SetMap(client_player_instance,"CiudadPrincipal")
	get_parent().get_node("SceneHandler/LoginScreen").hide()
	get_parent().get_node("SceneHandler/" + "CiudadPrincipal" +  "/MapElements/Player").set_physics_process(true)
