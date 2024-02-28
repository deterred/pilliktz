extends Node

@onready var main_menu = $CanvasLayer/MainMenu
@onready var adress_entry = $CanvasLayer/MainMenu/MarginContainer/VBoxContainer/AdressEntry
@onready var hud = $CanvasLayer/HUD
@onready var healthBar = $CanvasLayer/HUD/HealthBar
@onready var nicknameLab = $CanvasLayer/HUD/MarginContainer/nickname
@onready var msg =$CanvasLayer/HUD/MarginContainer/LineEdit 
@onready var playernickname = $CanvasLayer/MainMenu/MarginContainer/VBoxContainer/playernickname
const Player = preload("res://scenes/player.tscn")
const PORT = 135;
var enet_peer = ENetMultiplayerPeer.new();
var local_player_character
var peer_id 

var colors = ["000000", "33AFFF","33FFF3","33FF96","5EFF33","E9FF33","FF7133",\
			 "3339FF","DD33FF","FF33B5","CBC6C7","302E2F","7C93B9"];

	
func _unhandled_input(event):
	if Input.is_action_just_pressed("quit"):
		get_tree().quit();
		


func _on_host_button_pressed():
	print("host")
	main_menu.hide();
	hud.show();
	enet_peer.create_server(PORT)
	multiplayer.multiplayer_peer = enet_peer
	multiplayer.peer_connected.connect(add_player)
	multiplayer.peer_disconnected.connect(remove_player)
	
	
	nicknameLab.text = "SERVER"
	add_player(multiplayer.get_unique_id())
	
	#upnp_setup()
	

func _on_join_button_pressed():
	main_menu.hide();
	hud.show();
	nicknameLab.text = "CLI"
	enet_peer.create_client(adress_entry.text, PORT);
	multiplayer.multiplayer_peer = enet_peer;


func add_player(peer_id):
	print('joueur connecté ');
	var player = Player.instantiate();
	


	player.name = str(peer_id)
	
	print(player.name + " joined");

	add_child(player);

	if player.is_multiplayer_authority():
		player.setname(playernickname.text)
		player.health_changed.connect(update_health_bar);
		player.dead_changed.connect(update_dead_bar);
		
			
		player.set_color(Color(colors[randi()%10]))		


	
func remove_player(peer_id):
	var player = get_node_or_null(str(peer_id));
	if player:
		player.queue_free();
	

	
func update_health_bar(health_val):
	print("update_health_bar")
	healthBar.value = health_val;

func update_dead_bar(dead_val):
	print("update_dead")
	$CanvasLayer/HUD/deadcount.text = "Mort : "+str(dead_val)+" fois"



func _on_multiplayer_spawner_spawned(node):
	if node.is_multiplayer_authority():
		node.health_changed.connect(update_health_bar);
		node.dead_changed.connect(update_dead_bar);
		node.setname(playernickname.text)
		node.set_color(Color(colors[randi()%10]))
		


func upnp_setup():
	var upnp = UPNP.new()
	
	var discover_result = upnp.discover()
	assert(discover_result == UPNP.UPNP_RESULT_SUCCESS, \
		"UPNP Discover Failed! Error %s" % discover_result)

	assert(upnp.get_gateway() and upnp.get_gateway().is_valid_gateway(), \
		"UPNP Invalid Gateway!")

	var map_result = upnp.add_port_mapping(PORT)
	assert(map_result == UPNP.UPNP_RESULT_SUCCESS, \
		"UPNP Port Mapping Failed! Error %s" % map_result)
	
	print("Success! Join Address: %s" % upnp.query_external_address())


