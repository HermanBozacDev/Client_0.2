extends Node

var multiplayer_api: MultiplayerAPI
var peer: ENetMultiplayerPeer = ENetMultiplayerPeer.new()
var ip = "147.93.15.197"
var port = 1909
var token
var client_clock = 0
var decimal_collector : float = 0
var latency_array = []
var latency = 0
var delta_latency = 0 

"""FUNCIONES DE CONFIGURACION PRINCIPALES"""
func _physics_process(delta):
	client_clock += int (delta*1000) + delta_latency
	delta_latency -= delta_latency
	decimal_collector += (delta * 1000) - int(delta * 1000)
	if decimal_collector >= 1.00:
		client_clock += 1
		decimal_collector -= 1.00
func _ready():
	pass
func ConnectToServer():
	var result = peer.create_client(ip, port)
	if result != OK:
		#avisar con cartel
		return
	multiplayer_api = MultiplayerAPI.create_default_interface()  # Crear instancia de MultiplayerAPI
	multiplayer_api.multiplayer_peer = peer  # Establecer el peer de juego
	get_tree().set_multiplayer(multiplayer_api, self.get_path())  # Establecer la ruta para RPC
	multiplayer.connected_to_server.connect(_on_connection_success)
	multiplayer.connection_failed.connect(_on_connection_failed)
func _on_connection_failed() :
	#coneccion fail avisar con cartel
	pass
func _on_connection_success():
	var key = "FetchServerTime"
	var value = Time.get_ticks_msec()
	ClientSendDataToServer(key, value)
	var timer  = Timer.new()
	timer.wait_time = 0.5
	timer.autostart = true
	timer.timeout.connect(DetermineLatency)
	self.add_child(timer)
func DetermineLatency():
	var key = "DetermineLatency"
	var value = Time.get_ticks_msec()
	ClientSendDataToServer(key, value)

@rpc func ClientSendDataToServer(key, value):
	rpc_id(1,"ClientSendDataToServer",key, value)

@rpc func ServerSendDataToOneClient(_player_id,key,value):
	match key:
		"FetchServerTime":
			latency = (Time.get_ticks_msec() - value[1]) / 2 
			client_clock = value[0] + latency
		"DetermineLatency":
			latency_array.append((Time.get_ticks_msec()- value) / 2)
			if latency_array.size() == 9:
				var total_latency = 0
				latency_array.sort()
				var mid_point = latency_array[4]
				for i in range(latency_array.size()-1,-1,-1):
					if latency_array[i] >  (2 * mid_point) and latency_array[i] > 20:
						latency_array.erase(i)
					else:
						total_latency += latency_array[i]
				delta_latency = (total_latency / latency_array.size()) - latency
				latency = total_latency / latency_array.size()
				latency_array.clear()  
		"FetchToken":
			rpc_id(1,"ClientSendDataToServer",key,token)
		"TokenVresult":
			var login_screen = get_node("/root/SceneHandler/LoginScreen")
			if value == true:
				login_screen.ShowUserPanel()
			else:
				#login fail
				login_screen.ResetButtons()
		"PlayerPool":
			
			get_node("/root/SceneHandler/LoginScreen").PlayerPool(value)
		"PlayerDie":
			#quiero replicar algo como en el lineage que si te moris aparece un cartel para ira la ciudad 
			#asi me da mejor tiempo de limpiar variables y sincronizar y usar animacion de muerte del personaje
			PlayerData.SpawnClientPlayer(key,value)
		"SoundFx":
				var attack_sound = load("res://Scenes/Sounds/FX/Attack1Sound.tscn")
				var attack_sound_instance = attack_sound.instantiate()
				add_child(attack_sound_instance)
		"UpdateInventory":
			PlayerData.inventory_dic = value
		"UpdateSkills":
			PlayerData.learn_skill_dic = value
		"NewPlayerRegister":
			PlayerData.SpawnClientPlayer(key,value)
		"LoadPlayer":
			PlayerData.SpawnClientPlayer(key,value)
		"Teleport":
			PlayerData.SpawnClientPlayer(key,value)
		"EquipItem":
			PlayerData.EquipItem(value)
		"Information":
			print("volvi con iinformacion",value)
			var new_information_instance = load("res://Scenes/UI/InformationPanel.tscn").instantiate()
			new_information_instance.descriptionText = value[0]
			var node = get_node("/root/SceneHandler/CanvasLayer")
			node.add_child(new_information_instance)
@rpc func ServerSendDataToAllClients(key,value):
	match key:
		"DespawnPlayer":
			#aca tengo que modularizar para que lo mande al mapa actual
			#value = player_id
			if !get_node("../SceneHandler/CiudadPrincipal"):
				return
			get_node("../SceneHandler/CiudadPrincipal").DespawnPlayer(value)
		"SpawnAttack":
			#value = [a_position, animation_vector, spawn_time, a_rotation , map,player_id]
			if value[5] == multiplayer_api.get_unique_id():
				pass # this would be a moment to correct side predicctions
			else:
				get_node("/root/SceneHandler/" + str(value[4]) +  "/MapElements/OtherPlayers/" + str( value[5])).attack_dict[value[2]] = {"Position" : value[0], "AnimationVector" : value[1],"Rotation": value[3]}
				get_node("/root/SceneHandler/" + str(value[4]) +  "/MapElements/OtherPlayers/" + str( value[5])).attack()

@rpc func ServerSendWorldState(world_state):
	
	for map in world_state.keys():
		match map:
			"CiudadPrincipal":
				var ciudad_principal_node = get_node_or_null("../SceneHandler/CiudadPrincipal")
				if ciudad_principal_node == null:
					pass 
				else:
					ciudad_principal_node.UpdateWorldState(world_state)
			"Mapa2":
				var mapa2_node = get_node_or_null("../SceneHandler/Mapa2")
				if mapa2_node == null:
					pass 
				else:
					mapa2_node.UpdateWorldState(world_state)
