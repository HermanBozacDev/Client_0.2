extends Node2D

const interpolation_offset = 10
var player_spawn = preload("res://Scenes/Player/PlayerTemplate.tscn")
var instantiated_players = {}
var last_world_state = 0
var world_state_buffer = []
var eliminated_players 
@onready var other_players_node = get_node("MapElements/OtherPlayers")
var skullman= preload("res://Scenes/Enemies/SkullMan.tscn")



""" SPAWN OTROS JUGADORES """
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

"""DESPAWN OTROS JUGADORES"""
func DespawnPlayer(player_id):
	var player_node = other_players_node.get_node_or_null(str(player_id))
	if player_node:
		player_node.queue_free()
		instantiated_players.erase(player_id)
		eliminated_players = player_id

"""ACA ADMINISTRO  CUANDO TENGO ESTADOS FUTUROS Y CUANDO NO"""
func _physics_process(_delta):
	var render_time = GameServer.client_clock - interpolation_offset
	
	
	# Mantén solo los 3 estados más recientes
	if world_state_buffer.size() > 3:
		world_state_buffer.remove_at(0)
	
	if world_state_buffer.size() > 1:
		if world_state_buffer.size() > 2 and render_time > world_state_buffer[2].T:
			world_state_buffer.remove_at(0)
		if world_state_buffer.size() > 2:
			WithFutureState(render_time)
		elif render_time > world_state_buffer[1].T:
			NoFotureState(render_time)

"""CON ESTADO FUTURO"""
func WithFutureState(_render_time):

	for player in world_state_buffer[2].keys():
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


	for enemy in world_state_buffer[2]["Mapa2"].keys():
		if not world_state_buffer[1]["Mapa2"].has(enemy):
			#si no existia en el estado anterior
			continue
		if get_node("MapElements/Enemies").has_node(str(enemy)):
			var new_position = lerp(world_state_buffer[1]["Mapa2"][enemy]["P"],world_state_buffer[2]["Mapa2"][enemy]["P"], 1)
			var animation_vector = world_state_buffer[1]["Mapa2"][enemy]["A"]
			get_node("MapElements/Enemies/" + str(enemy)).state = world_state_buffer[1]["Mapa2"][enemy]["S"]
			get_node("MapElements/Enemies/" + str(enemy)).MoveEnemy(new_position)
			get_node("MapElements/Enemies/" + str(enemy)).Health(world_state_buffer[1]["Mapa2"][enemy]["Health"]) 
			get_node("MapElements/Enemies/" + str(enemy)).AnimationMode(animation_vector)
		else:
			if world_state_buffer[2]["Mapa2"][enemy]["Health"] <= 0:
				pass
			else:
				SpawnNewEnemy(enemy, world_state_buffer[2]["Mapa2"][enemy])

"""SIN ESTADO FUTURO   (ESTO LO VOY A TERMINAR BORRANDO A LA MIERDA PORQUE LO DE ESTADO FUTOROY NO ES PARA
INTERPOLACION Y EXTRAPOLACION OSEA NO ESTOY USANDO ESTO TENDRIA QUE SER SIEMPER COMO ESTA EN ESTADO FUTURO
Y HACERLO SIEMPRE QUE WORLD STATE SEA MAYOR A 0 IMAGINO YO) """
func NoFotureState(_render_time):
	for player in world_state_buffer[1].keys():
		if str(player) in ["T", "CiudadPrincipal"]:
			continue
		if player == str(GameServer.multiplayer_api.get_unique_id()):
			continue
		if not world_state_buffer[0].has(player):
			continue
		if other_players_node.has_node(str(player)):
			var new_position =  Vector2(world_state_buffer[1][player]["Px"], world_state_buffer[1][player]["Py"])
			var animation_vector = world_state_buffer[1][player]["A"]
			other_players_node.get_node(str(player)).MovePlayer(new_position,animation_vector)

"""ACTUALIZO EL WORLD STATE CON EL ESTADO QUE LLEGA DEL SERVIDOR"""
func UpdateWorldState(world_state):
	if world_state["T"] > last_world_state:
		last_world_state = world_state["T"]
		world_state_buffer.append(world_state)

"""SPAWN ENEMY NO SE USA EN CIUDAD PRINCIPAL"""
func SpawnNewEnemy(enemy_id, enemy_dict):
	var type = enemy_dict["T"]
	match type:
		"SkullMan":
			SpawnSkullMan(enemy_id, enemy_dict)

"""FUNCION PARA SPAWNEAR SKULLMANS NO SE USA EN ESTE SCRIPT PORQUE ES CIUDAD"""
func SpawnSkullMan(enemy_id, enemy_dict):
	var new_enemy = skullman.instantiate()
	new_enemy.position = enemy_dict["P"]
	new_enemy.max_hp = enemy_dict["MHealth"]
	new_enemy.current_hp = enemy_dict["Health"]
	new_enemy.type = enemy_dict["T"]
	new_enemy.state = enemy_dict["S"] 
	new_enemy.name = str(enemy_id)
	get_node("MapElements/Enemies/").add_child(new_enemy, true)
