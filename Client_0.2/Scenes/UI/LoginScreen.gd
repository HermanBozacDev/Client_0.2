extends Control
#PANELES
@onready var login_screen: VBoxContainer =   $Backgroun/Panel/LoginScreen
@onready var create_account: VBoxContainer = $Backgroun/Panel/CreateAccount
@onready var user_panel: VBoxContainer =     $Backgroun/Panel/UserPanel
@onready var load_player: VBoxContainer =    $Backgroun/Panel/LoadPlayer
@onready var select_name: VBoxContainer =    $Backgroun/Panel/SelectName
@onready var select_type: VBoxContainer =    $Backgroun/Panel/SelectType
@onready var select_class: VBoxContainer =   $Backgroun/Panel/SelectClass
@onready var confirm_screen: VBoxContainer = $Backgroun/Panel/ConfirmScreen
#LOGIN SCREEN
@onready var username_input =        $Backgroun/Panel/LoginScreen/User/UserText
@onready var userpassword_input =    $Backgroun/Panel/LoginScreen/Pass/PassText
@onready var login_button =          $Backgroun/Panel/LoginScreen/Buttons/Login
@onready var create_account_button = $Backgroun/Panel/LoginScreen/Buttons/CreateAccount
#CREATE ACCOUNT
@onready var create_username_input =             $Backgroun/Panel/CreateAccount/aux/aux/Username/Username
@onready var create_userpassword_input =         $Backgroun/Panel/CreateAccount/aux/aux/Password/Password
@onready var  create_userpassword_repeat_input = $Backgroun/Panel/CreateAccount/aux/aux/RepeatPassword/RepeatPassword
@onready var  confirm_button =                   $Backgroun/Panel/CreateAccount/aux/Buttons/Confirm
@onready var  back_button =                      $Backgroun/Panel/CreateAccount/aux/Buttons/BackToLogin
#SELECT CHARACTER NAME
@onready var create_new_player_name = $Backgroun/Panel/SelectName/Username

var player_pool

var username
var nickname 
var new_class
var new_type
var alert = preload("res://Scenes/UI/Alert.tscn")
func InstanceAlert(text):
	var new_alert = alert.instantiate()
	new_alert.text = text
	get_node("/root/SceneHandler/CanvasLayer").add_child(new_alert)
func ShowUserPanel():
	login_screen.hide()
	user_panel.show()
func ResetButtons():
	login_button.disabled = false
	create_account_button.disabled = false

"""BUTTONS """
func _on_exit_pressed() -> void:
	get_tree().quit()
func _on_back_to_login_pressed() -> void:
	create_account.hide()
	login_screen.show()
"""CREAR NUEVA CUENTA"""
func _on_create_account_pressed() -> void:
	login_screen.hide()
	create_account.show()
func _on_confirm_pressed() -> void:
	if create_username_input.get_text() == "":
		InstanceAlert("please provide a valid  username")
	elif create_userpassword_input.get_text() == "":
		InstanceAlert("please provide a valid pasword")
	elif create_userpassword_repeat_input.get_text() == "":
		InstanceAlert("please repeat your password")
	elif create_userpassword_input.get_text() != create_userpassword_repeat_input.get_text():
		InstanceAlert("Passwords dont match")
	elif create_userpassword_input.get_text().length() <= 6:
		InstanceAlert("Password must contain  at least 7 characters")
	else:
		confirm_button.disabled = true
		back_button.disabled =  true
		var inputing_username = create_username_input.get_text()
		var inputing_ = create_userpassword_input.get_text()
		Gateway.connect_to_server(inputing_username, inputing_, true)

"""LOGIN """
func _on_login_pressed() -> void:
	if username_input.text == "" or userpassword_input.text == "":
		InstanceAlert("Please provide valid userID and password")
	else:
		login_button.disabled = true
		username = username_input.get_text()
		var password = userpassword_input.get_text()
		Gateway.connect_to_server(username,password,false)

"""USER OPTIONS"""
func _on_back_pressed() -> void:
	nickname = ""
	new_class = ""
	new_type = ""
	select_class.hide()
	select_type.hide()
	select_name.hide()
	confirm_screen.hide()
	user_panel.show()
func _on_new_player_pressed() -> void:
	user_panel.hide()
	select_name.show()
func _on_load_player_pressed() -> void:
	var new_username = Gateway.username
	var key = "PlayerPool"
	GameServer.ClientSendDataToServer(key,new_username)



"""NEW CHARACTER"""
func _on_pick_class_pressed() -> void:
	if create_new_player_name.text == "":
		InstanceAlert("Please provide valid nickname")
	else:
		#create_new_player_button.disabled = true
		var new_nickname = create_new_player_name.get_text()
		nickname = new_nickname
		select_name.hide()
		select_class.show()
func _on_elf_pressed() -> void:
	new_class = "elf"
	select_class.hide()
	select_type.show()
func _on_dark_elf_pressed() -> void:
	new_class = "darkelf"
	select_class.hide()
	select_type.show()
func _on_human_pressed() -> void:
	new_class = "human"
	select_class.hide()
	select_type.show()
func _on_orc_pressed() -> void:
	new_class = "orc"
	select_class.hide()
	select_type.show()
func _on_dwarf_pressed() -> void:
	new_class = "dwarf"
	select_class.hide()
	select_type.show()
func _on_fighter_pressed() -> void:
	new_type = "fighter"
	select_type.hide()
	confirm_screen.show()	
func _on_wizard_pressed() -> void:
	new_type = "wizard"
	select_type.hide()
	confirm_screen.show()
#CONFIRM NEW CHARACTER CREATED
func _on_create_new_player_pressed() -> void:
	var key = "NewPlayerRegister"
	var value = [username,nickname,new_class,new_type]
	GameServer.ClientSendDataToServer(key, value)


"""LOAD CHARACTER"""

func PlayerPool(new_player_pool):
	print("new_player_pool",new_player_pool)
	player_pool = new_player_pool
	for acount in new_player_pool:
		for character in new_player_pool[acount]:
			var load_slot = load("res://Scenes/UI/LoadSlot.tscn")
			var new_load_instance = load_slot.instantiate()
			new_load_instance.slot_name = character
			new_load_instance.slot_level = new_player_pool[acount][character].level
			get_node("Backgroun/Panel/LoadPlayer/LoadPlayer").add_child(new_load_instance)
	user_panel.hide()
	load_player.show()
	

"""USER PANEL"""
func OnLoadPressed(new_nickname):
	var key = "LoadPlayer"
	GameServer.ClientSendDataToServer(key, new_nickname)


	
func OnDeletePressed(new_nickname):
	pass
	#GameServer.RemoveCharacterFromAccount(new_nickname, username)
	
	