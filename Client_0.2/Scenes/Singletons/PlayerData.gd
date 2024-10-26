extends Node


"""NICKNAME"""
var player_name
var player_map = "CiudadPrincipal"
var player_class
var player_load = false
var is_respawning = false


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
var move_item
var numero_boton_apretado
var selected = false
var procesando_boton = false
var hotbar = preload("res://Scenes/UI/Hotbar.tscn")
var player_view = preload("res://Scenes/UI/PlayerView.tscn")
var client_player_scene = load("res://Scenes/Player/player.tscn")




"""PARA EL PLAYER VIEW"""
func GetCurrentHp():
	return stats_dic["health"]
func GetCurrentMp():
	return stats_dic["mana"]
func GetCurrentMaxHp():
	return stats_dic["maxhealth"]
func GetCurrentMaxMp():
	return stats_dic["maxmana"]
func GetName():
	return player_name
func GetLevel():
	return stats_dic["level"]
	
func GetExp():
	return stats_dic["exp"]
func GetReqExp():
	return stats_dic["expRequerida"]





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
			#print("PlayerData.learn_skill_dic",PlayerData.learn_skill_dic)
			#print("id_boton_apretado",id_boton_apretado)
			match PlayerData.learn_skill_dic[id_boton_apretado][2]:
				"RangedSingleTargetSkill":
					RangedSingleTargetSkill()
				"TargetBuff":
					print("entre en target buff alfin")
					TargetBuffSkill()
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
	var skill = preload("res://Scenes/Skills/SingleTargetRangedSkill.tscn")
	skill_instance = skill.instantiate()
	get_tree().get_nodes_in_group("Jugador")[0].set_variables()
	get_tree().get_nodes_in_group("Jugador")[0].get_node("TurnAxis").rotation = get_tree().get_nodes_in_group("Jugador")[0].angle_to_mouse_position
	skill_instance.rotation = get_tree().get_nodes_in_group("Jugador")[0].get_node("TurnAxis").rotation
	skill_instance.position = get_tree().get_nodes_in_group("Jugador")[0].get_node("TurnAxis/Position2D").get_global_position()
	skill_instance.projectile_speed = PlayerData.learn_skill_dic[id_boton_apretado][3]
	skill_instance.skill_name = id_boton_apretado
	var attack_type = PlayerData.learn_skill_dic[id_boton_apretado][2]
	get_tree().get_nodes_in_group("Jugador")[0].Attack(skill_instance.rotation,skill_instance.position,id_boton_apretado,skill_instance,attack_type)

func TargetBuffSkill():
	var skill = preload("res://Scenes/Skills/TargetBuff.tscn")
	skill_instance = skill.instantiate()
	skill_instance.position = get_tree().get_nodes_in_group("Jugador")[0].get_global_mouse_position()
	get_tree().get_nodes_in_group("Jugador")[0].get_parent().add_child(skill_instance)

func CanvasItems():
	var hotbar_instance = hotbar.instantiate()
	get_node("/root/SceneHandler/CanvasLayer").add_child(hotbar_instance)
	var player_view_instance = player_view.instantiate()
	get_node("/root/SceneHandler/CanvasLayer").add_child(player_view_instance)

#aca deberia matchear entre new load y teleport
func SpawnClientPlayer(key,value):
	match key:
		"NewPlayerRegister":
			NewPlayerRegister(value)
		"LoadPlayer":
			LoadPlayer(value)
		"Teleport":
			Teleport(value)
		"PlayerDie":
			print("PlayerDie",value)
			KillingPlayer(value)




func NewPlayerRegister(value):
	stats_dic = value[0]
	learn_skill_dic = value[4]
	player_name = value[5]
	player_map = value[0]["M"]
	player_class = value[0]["type"]
	var client_player_instance = client_player_scene.instantiate()
	get_node("/root/SceneHandler").SetMap(client_player_instance,"CiudadPrincipal")
	get_parent().get_node("SceneHandler/LoginScreen").hide()
	get_parent().get_node("SceneHandler/" + "CiudadPrincipal" +  "/MapElements/Player").set_physics_process(true)
	CanvasItems()

func LoadPlayer(value):
	stats_dic = value[0]
	learn_skill_dic = value[4]
	player_name = value[5]
	player_map = value[0]["M"]
	player_class = value[0]["type"]
	inventory_dic = value[1]
	hot_bar_dic = value[2]
	equip_item_dic = value[3]
	var client_player_instance = client_player_scene.instantiate()
	get_node("/root/SceneHandler").SetMap(client_player_instance,value[0]["M"])
	get_parent().get_node("SceneHandler/LoginScreen").hide()
	get_parent().get_node("SceneHandler/" + value[0]["M"] +  "/MapElements/Player").set_physics_process(true)
	CanvasItems()

func Teleport(value):
	var client_player_instance = client_player_scene.instantiate()
	get_node("/root/SceneHandler/" + value[0]).queue_free()
	client_player_instance.position = value[3]
	PlayerData.player_map = value[1]
	for player in get_tree().get_nodes_in_group("Map"):
		print("map",player.name)
		player.queue_free()
	get_node("/root/SceneHandler").SetMap(client_player_instance,value[1])
	get_node("/root/SceneHandler/" + value[1] +  "/MapElements/Player").set_physics_process(true)

func KillingPlayer(value):
	#value = defeat_map
	if is_respawning:
		return  # Evitar procesamiento duplicado de la muerte
	get_node("/root/SceneHandler/DeadWindows").show()
	is_respawning = true
	print("Player is dying on the client...")
	# Desaparece al jugador actual
	get_node("/root/SceneHandler/" + value  +"/MapElements/Player").queue_free()
	# Espera antes de respawn
	await get_tree().create_timer(2).timeout
	# Carga y reaparece al nuevo jugador
	PlayerData.player_load = true
	var client_player_scene = load("res://Scenes/Player/player.tscn")
	var client_player_instance = client_player_scene.instantiate()
	PlayerData.stats_dic["M"] = "CiudadPrincipal"
	PlayerData.stats_dic["Px"] = 0
	PlayerData.stats_dic["Py"] = 0
	
	var spawn_point = Vector2.ZERO
	client_player_instance.map = PlayerData.stats_dic["M"]
	get_node("../SceneHandler").SetMapThenDie(client_player_instance, "CiudadPrincipal")
	# Espera para asegurarse de que el jugador reaparezca correctamente
	await get_tree().create_timer(1).timeout
	get_node("/root/SceneHandler/DeadWindows").hide()
	# Reubicar al nuevo jugador
	get_parent().get_node("SceneHandler/" + str(PlayerData.stats_dic["M"]) + "/MapElements/Player").position = spawn_point

	# Reinicia la bandera de respawn
	is_respawning = false
