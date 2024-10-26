extends Node

var ciudadPrincipal = preload("res://Scenes/Maps/CiudadPrincipal.tscn")
var mapa2 = preload("res://Scenes/Maps/Mapa2.tscn")

func SetMap(client_player_instance,map):
	var map_music = load("res://Scenes/Sounds/CiudadPrincipalBackSound.tscn").instantiate()
	if get_tree().get_nodes_in_group("Map").size() > 0:
		get_tree().get_nodes_in_group("Map")[0].queue_free()
	match map:
		"CiudadPrincipal":
			print("aca")
			var mapaCiudadPrincipal = ciudadPrincipal.instantiate()
			mapaCiudadPrincipal.name = "CiudadPrincipal"
			add_child(mapaCiudadPrincipal)
			get_node("CiudadPrincipal/MapElements").add_child(client_player_instance)
			get_node("CiudadPrincipal").add_child(map_music)
		"Mapa2":
			print("aca 2")
			var mapa2_instance = mapa2.instantiate()
			mapa2_instance.set_name("Mapa2")
			add_child(mapa2_instance)
			get_node("Mapa2/MapElements").add_child(client_player_instance)
			get_node("Mapa2").add_child(map_music)




func SetMapThenDie(client_player_instance,map):
	var map_music = load("res://Scenes/Sounds/CiudadPrincipalBackSound.tscn").instantiate()
	if get_tree().get_nodes_in_group("Map").size() > 0:
		get_tree().get_nodes_in_group("Map")[0].queue_free()
	await(get_tree().create_timer(1).timeout)
	match map:
		"CiudadPrincipal":
				var mapaCiudadPrincipal = ciudadPrincipal.instantiate()
				mapaCiudadPrincipal.name = "CiudadPrincipal"
				add_child(mapaCiudadPrincipal)
				get_node("CiudadPrincipal/MapElements").add_child(client_player_instance)
				get_node("CiudadPrincipal").add_child(map_music)
