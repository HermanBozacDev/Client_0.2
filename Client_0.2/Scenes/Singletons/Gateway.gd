extends Node

var multiplayer_api: MultiplayerAPI
var peer: ENetMultiplayerPeer = ENetMultiplayerPeer.new()
var ip: String = "127.0.0.1"  # Cambia la IP si es necesario
var port: int = 1910  # Debe coincidir con el puerto del servidor
var username
var password
var new_account

var alert = preload("res://Scenes/UI/Alert.tscn")


func InstanceAlert(text):
	var new_alert = alert.instantiate()
	new_alert.text = text
	get_node("/root/SceneHandler/CanvasLayer").add_child(new_alert)


"""FUNCIONES DE CONFIGURACION PRINCIPALES"""

func connect_to_server(_username, _password,_new_account):
	var result = peer.create_client(ip, port)
	if result != OK:
		print("Error al intentar conectarse al servidor:", result)
		return
	multiplayer_api = MultiplayerAPI.create_default_interface()  # Crear instancia de MultiplayerAPI
	multiplayer_api.multiplayer_peer = peer  # Establecer el peer de juego
	get_tree().set_multiplayer(multiplayer_api, self.get_path())  # Establecer la ruta para RPC
	username = _username
	print("usernameadsasd",username)
	password = _password
	new_account = _new_account
	multiplayer.connected_to_server.connect(_on_connection_success)
	multiplayer.connection_failed.connect(_on_connection_failed)


func _on_connection_failed():
	InstanceAlert("Error al conectarse al servidor")

func _on_connection_success():
	if  new_account == true:
		RequestCreateAccount()
	else:
		LoginRequest()

@rpc func RequestCreateAccount():
	rpc_id(1,"CreateAccountRequest", username, password.sha256_text())
	username = ""
	password = ""

@rpc func ReturnCreateAccountRequest(result, message):
	if result == true:
		print("CREE NUEVA CUENTA   Y ME DESCONECTO DEL GATEWAY")
		get_node("../SceneHandler/LoginScreen")._on_back_to_login_pressed()
		multiplayer_api.multiplayer_peer.close()
		
			
	else:
		if message == 1:
			InstanceAlert("Couldnt create account, please try again")
		elif message ==2:
			InstanceAlert("The username already exist, please use  a different")
		get_node("../SceneHandler/LoginScreen").confirm_button.disabled = false
		get_node("../SceneHandler/LoginScreen").back_button.disabled = false



"""FUNCIONES SIN APLICAR"""


@rpc func LoginRequest():
	rpc_id(1,"LoginRequest",username, password.sha256_text())
	password = ""

@rpc func ReturnLoginRequest(results,token):
	print("ACA ME AUTORIZA EL GATEWAY PARA ENTRAR AL SERVER NUEVO TOKEN")
	if results == true:
		GameServer.token = token
		GameServer.ConnectToServer()
	else:
		InstanceAlert("Please provide correct username and password")
		get_node("../SceneHandler/LoginScreen").ResetButtons()
	#aca iba las desconeccicones a las señales pero me bugean las funciones.
	
	
	
"""FUNCIONES ESPEJO"""
@rpc func CreateAccountRequest(_new_username, _new_password):
	pass
