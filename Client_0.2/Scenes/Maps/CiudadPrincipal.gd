extends Node2D

const interpolation_offset = 10
var player_spawn = preload("res://Scenes/Player/PlayerTemplate.tscn")
var instantiated_players = {}
var last_world_state = 0
var world_state_buffer = []
var eliminated_players 
@onready var other_players_node = get_node("MapElements/OtherPlayers")
var skullman= preload("res://Scenes/Enemies/SkullMan.tscn")




"""Función para instanciar otros jugadores"""
func SpawnNewPlayer(player_id, spawn_position,player_stats):
	if int(player_id) == GameServer.multiplayer_api.get_unique_id():
		return # No instancias a ti mismo
	if not other_players_node.has_node(str(player_id)):
		var new_player = player_spawn.instantiate()
		new_player.position = spawn_position
		new_player.name = str(player_id)
		new_player.player_stats = player_stats
		other_players_node.add_child(new_player)
		instantiated_players[player_id] = new_player

"""Función para eliminar jugadores"""
func DespawnPlayer(player_id):
	var player_node = other_players_node.get_node_or_null(str(player_id))
	if player_node:
		player_node.queue_free()
		instantiated_players.erase(player_id)
		eliminated_players = player_id

func _physics_process(_delta):
	var render_time = GameServer.client_clock - interpolation_offset
	# Mantén solo los 3 estados más recientes
	if world_state_buffer.size() > 3:
		world_state_buffer.remove_at(0)
	if world_state_buffer.size() > 1:
		#print("WORLD STATE EN CIUDAD PRINCIPAL",world_state_buffer[0]["CiudadPrincipal"])
		if world_state_buffer.size() > 2 and render_time > world_state_buffer[2].T:
			world_state_buffer.remove_at(0)
		if world_state_buffer.size() > 2:
			WithFutureState()
		elif render_time > world_state_buffer[1].T:
			NoFotureState()

func WithFutureState():
	for player in world_state_buffer[2].keys():
		#print("player with sfuture state",player)
		if str(player) in ["T", "CiudadPrincipal"]:
			continue
		if str(player) == "Mapa2":
			continue
		if player == str(GameServer.multiplayer_api.get_unique_id()):
			continue
		if not world_state_buffer[1].has(player):
			continue
		if other_players_node.has_node(str(player)):

			var new_position =Vector2(world_state_buffer[2][player]["Px"], world_state_buffer[2][player]["Py"])
			var animation_vector = world_state_buffer[2][player]["A"]
			other_players_node.get_node(str(player)).MovePlayer(new_position,animation_vector)
		else:
			if  str(player) == str(eliminated_players):
				return
			var new_position = Vector2(world_state_buffer[2][player]["Px"], world_state_buffer[2][player]["Py"])
			var player_stats = world_state_buffer[2][player]
			SpawnNewPlayer(player, new_position,player_stats)


	
	for enemy in world_state_buffer[2]["CiudadPrincipal"].keys():
		if not world_state_buffer[1]["CiudadPrincipal"].has(enemy):
			#si no existia en el estado anterior
			continue
		if get_node("MapElements/Enemies").has_node(str(enemy)):
			var new_position = lerp(world_state_buffer[1]["CiudadPrincipal"][enemy]["P"],world_state_buffer[2]["CiudadPrincipal"][enemy]["P"], 1)
			var animation_vector = world_state_buffer[1]["CiudadPrincipal"][enemy]["A"]
			get_node("MapElements/Enemies/" + str(enemy)).state = world_state_buffer[1]["CiudadPrincipal"][enemy]["S"]
			get_node("MapElements/Enemies/" + str(enemy)).MoveEnemy(new_position)
			get_node("MapElements/Enemies/" + str(enemy)).Health(world_state_buffer[1]["CiudadPrincipal"][enemy]["Health"]) 
			get_node("MapElements/Enemies/" + str(enemy)).AnimationMode(animation_vector)
		else:
			if world_state_buffer[2]["CiudadPrincipal"][enemy]["Health"] <= 0:
				pass
			else:
				SpawnNewEnemy(enemy, world_state_buffer[2]["CiudadPrincipal"][enemy])

func NoFotureState():
	for player in world_state_buffer[1].keys():
		if str(player) in ["T", "CiudadPrincipal"]:
			continue
		if str(player) == "Mapa2":
			continue
		if player == str(GameServer.multiplayer_api.get_unique_id()):
			continue
		if not world_state_buffer[0].has(player):
			continue
		if other_players_node.has_node(str(player)):
			var new_position =  Vector2(world_state_buffer[1][player]["Px"], world_state_buffer[1][player]["Py"])
			var animation_vector = world_state_buffer[1][player]["A"]
			other_players_node.get_node(str(player)).MovePlayer(new_position,animation_vector)




func UpdateWorldState(world_state):
	#print("funciona normal")
	if world_state["T"] > last_world_state:
		last_world_state = world_state["T"]
		world_state_buffer.append(world_state)

func SpawnNewEnemy(enemy_id, enemy_dict):
	var type = enemy_dict["T"]
	match type:
		"SkullMan":
			SpawnSkullMan(enemy_id, enemy_dict)

func SpawnSkullMan(enemy_id, enemy_dict):
	var new_enemy = skullman.instantiate()
	new_enemy.position = enemy_dict["P"]
	new_enemy.max_hp = enemy_dict["MHealth"]
	new_enemy.current_hp = enemy_dict["Health"]
	new_enemy.type = enemy_dict["T"]
	new_enemy.state = enemy_dict["S"] 
	new_enemy.name = str(enemy_id)
	get_node("MapElements/Enemies/").add_child(new_enemy, true)





"""



func NoFotureState(render_time):
	var extrapolation_factor = float(render_time - world_state_buffer[0]["T"]) / float(world_state_buffer[1]["T"] - world_state_buffer[0]["T"])
	for player in world_state_buffer[1].keys():
		if str(player) in ["T", "CiudadPrincipal"]:
			continue
		if player == str(GameServer.multiplayer_api.get_unique_id()):
			continue
		if not world_state_buffer[0].has(player):
			continue
		if other_players_node.has_node(str(player)):
			var new_position1 = Vector2(world_state_buffer[1][player]["Px"], world_state_buffer[1][player]["Py"])
			var new_position2 = Vector2(world_state_buffer[0][player]["Px"], world_state_buffer[0][player]["Py"])
			var position_delta = new_position1 - new_position2
			var new_position = new_position1 + (position_delta * extrapolation_factor)
			var animation_vector = world_state_buffer[1][player]["A"]
			other_players_node.get_node(str(player)).MovePlayer(new_position,animation_vector)



func WithFutureState(render_time):
	var interpolation_factor = float(render_time - world_state_buffer[1]["T"]) / float(world_state_buffer[2]["T"] - world_state_buffer[1]["T"])
	for player in world_state_buffer[2].keys():
		if str(player) in ["T", "CiudadPrincipal"]:
			continue
		if player == str(GameServer.multiplayer_api.get_unique_id()):
			continue
		if not world_state_buffer[1].has(player):
			continue
		if other_players_node.has_node(str(player)):
			var position1 = Vector2(world_state_buffer[1][player]["Px"], world_state_buffer[1][player]["Py"])
			var position2 = Vector2(world_state_buffer[2][player]["Px"], world_state_buffer[2][player]["Py"])
			var new_position = position1.lerp(position2, interpolation_factor)
			var animation_vector = world_state_buffer[2][player]["A"]
			other_players_node.get_node(str(player)).MovePlayer(new_position,animation_vector)
		else:
			if  str(player) == str(eliminated_players):
				return
			var new_position = Vector2(world_state_buffer[2][player]["Px"], world_state_buffer[2][player]["Py"])
			var player_stats = world_state_buffer[2][player]
			SpawnNewPlayer(player, new_position,player_stats)
	for enemy in world_state_buffer[2]["CiudadPrincipal"].keys():
		if not world_state_buffer[1]["CiudadPrincipal"].has(enemy):
			#si no existia en el estado anterior
			continue
		if get_node("MapElements/Enemies").has_node(str(enemy)):
			var new_position = lerp(world_state_buffer[1]["CiudadPrincipal"][enemy]["P"],world_state_buffer[2]["CiudadPrincipal"][enemy]["P"], 1)
			var animation_vector = world_state_buffer[1]["CiudadPrincipal"][enemy]["A"]
			get_node("MapElements/Enemies/" + str(enemy)).state = world_state_buffer[1]["CiudadPrincipal"][enemy]["S"]
			get_node("MapElements/Enemies/" + str(enemy)).MoveEnemy(new_position)
			get_node("MapElements/Enemies/" + str(enemy)).Health(world_state_buffer[1]["CiudadPrincipal"][enemy]["H"]) 
			get_node("MapElements/Enemies/" + str(enemy)).AnimationMode(animation_vector)
		else:
			if world_state_buffer[2]["CiudadPrincipal"][enemy]["H"] <= 0:
				pass
			else:
				SpawnNewEnemy(enemy, world_state_buffer[2]["CiudadPrincipal"][enemy])





"""
