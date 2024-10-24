extends Node

var ciudadPrincipal = preload("res://Scenes/Maps/CiudadPrincipal.tscn")


func SetMap(client_player_instance,map):
	var map_music = load("res://Scenes/Sounds/CiudadPrincipalBackSound.tscn").instantiate()
	if get_tree().get_nodes_in_group("Map").size() > 0:
		get_tree().get_nodes_in_group("Map")[0].queue_free()
	match map:
		"CiudadPrincipal":
				var mapaCiudadPrincipal = ciudadPrincipal.instantiate()
				mapaCiudadPrincipal.name = "CiudadPrincipal"
				print("")
				add_child(mapaCiudadPrincipal)
				get_node("CiudadPrincipal/MapElements").add_child(client_player_instance)
				get_node("CiudadPrincipal").add_child(map_music)





func SetMapThenDie(client_player_instance,map):
	var map_music = load("res://Scenes/Sounds/CiudadPrincipalBackSound.tscn").instantiate()
	if get_tree().get_nodes_in_group("Map").size() > 0:
		get_tree().get_nodes_in_group("Map")[0].queue_free()
	await(get_tree().create_timer(1).timeout)
	match map:
		"CiudadPrincipal":
				var mapaCiudadPrincipal = ciudadPrincipal.instantiate()
				mapaCiudadPrincipal.name = "CiudadPrincipal"
				print("")
				add_child(mapaCiudadPrincipal)
				get_node("CiudadPrincipal/MapElements").add_child(client_player_instance)
				get_node("CiudadPrincipal").add_child(map_music)
