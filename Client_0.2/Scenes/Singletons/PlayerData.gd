extends Node


"""DICCIONARIOS"""
var stats_dic = {}
var inventory_dic = {}
var equip_item_dic = {}
var hot_bar_dic = {}
var learn_skill_dic = {}





var player_name




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
