extends Node

var multiplayer_api: MultiplayerAPI
var peer: ENetMultiplayerPeer = ENetMultiplayerPeer.new()
var ip = "127.0.0.1"
var port = 1909
var token
var client_clock = 0
var decimal_collector : float = 0
var latency_array = []
var latency = 0
var delta_latency = 0 
var is_respawning = false

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
		print("Error al intentar conectarse al servidor:", result)
		return
	multiplayer_api = MultiplayerAPI.create_default_interface()  # Crear instancia de MultiplayerAPI
	multiplayer_api.multiplayer_peer = peer  # Establecer el peer de juego
	get_tree().set_multiplayer(multiplayer_api, self.get_path())  # Establecer la ruta para RPC
	multiplayer.connected_to_server.connect(_on_connection_success)
	multiplayer.connection_failed.connect(_on_connection_failed)
func _on_connection_failed() :
	print("failed to conect to Game server")
func _on_connection_success():
	print("CONNECTION SUCCES TO GAMESERVER")
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
				print("successful token verification")
				print("ID DEL CLIENTE",multiplayer_api.get_unique_id())
				login_screen.ShowUserPanel()
			else:
				print("Login failed, please try again")
				login_screen.ResetButtons()
		"NewPlayerRegister":
			#value[stats,skills_learn]
			PlayerData.stats_dic = value[0]
			PlayerData.learn_skill_dic = value[1]
			PlayerData.player_name = value[2]
			var client_player_scene = load("res://Scenes/Player/player.tscn")
			var client_player_instance = client_player_scene.instantiate()
			get_node("/root/SceneHandler").SetMap(client_player_instance,"CiudadPrincipal")
			get_parent().get_node("SceneHandler/LoginScreen").hide()
			get_parent().get_node("SceneHandler/" + "CiudadPrincipal" +  "/MapElements/Player").set_physics_process(true)
		"PlayerPool":
			get_node("/root/SceneHandler/LoginScreen").PlayerPool(value)
		"LoadPlayer":
			#value = [stats[0],inventory[1],hotbar[2],equipitem[3],learnskill[4],nickname[5]
			PlayerData.SpawnClientPlayer(value)
		"PlayerDie":
			get_node("/root/SceneHandler/CanvasLayer/Hotbar").hide()
			get_node("/root/SceneHandler/CanvasLayer/PlayerView").hide()
			get_node("/root/SceneHandler/CanvasLayer/Dead").show()
			if is_respawning:
				return  # Evitar procesamiento duplicado de la muerte
			is_respawning = true
			print("Player is dying on the client...")
			# Desaparece al jugador actual
			get_node("/root/SceneHandler/CiudadPrincipal/MapElements/Player").queue_free()
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
			get_node("/root/SceneHandler/CanvasLayer/Hotbar").show()
			get_node("/root/SceneHandler/CanvasLayer/PlayerView").show()
			get_node("/root/SceneHandler/CanvasLayer/Dead").hide()
			# Reubicar al nuevo jugador
			get_parent().get_node("SceneHandler/" + str(PlayerData.stats_dic["M"]) + "/MapElements/Player").position = spawn_point
			get_parent().get_node("SceneHandler/" + str(PlayerData.stats_dic["M"]) + "/MapElements/Player").set_physics_process(true)
			# Reinicia la bandera de respawn
			is_respawning = false
		"SoundFx":
				var attack_sound = load("res://Scenes/Sounds/FX/Attack1Sound.tscn")
				var attack_sound_instance = attack_sound.instantiate()
				add_child(attack_sound_instance)
		"UpdateInventory":
			print("despues de matar un enemigo recivo un nuevo inventario")
			PlayerData.inventory_dic = value
		"UpdateSkills":
			PlayerData.learn_skill_dic = value

@rpc func ServerSendDataToAllClients(key,value):
	match key:
		"DespawnPlayer":
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
	var ciudad_principal_node = get_node_or_null("../SceneHandler/CiudadPrincipal")
	if ciudad_principal_node == null:
		return # Evita seguir si el nodo aún no existe
	ciudad_principal_node.UpdateWorldState(world_state)
