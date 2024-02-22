extends Node

@onready var main_menu = $CanvasLayer/MainMenu
@onready var adress_entry = $CanvasLayer/MainMenu/MarginContainer/VBoxContainer/AdressEntry

const Player = preload("res://scenes/player.tscn")
const PORT = 135;
var enet_peer = ENetMultiplayerPeer.new();


func _unhandled_input(event):
	if Input.is_action_just_pressed("quit"):
		get_tree().quit();
		


func _on_host_button_pressed():
	print("host")
	main_menu.hide();
	enet_peer.create_server(PORT)
	multiplayer.multiplayer_peer = enet_peer
	multiplayer.peer_connected.connect(add_player)
	#multiplayer.peer_disconnected.connect(remove_player)
	
	add_player(multiplayer.get_unique_id())
	
	#upnp_setup()
	


func _on_join_button_pressed():
	
	main_menu.hide();
	enet_peer.create_client("localhost", PORT);
	multiplayer.multiplayer_peer = enet_peer;


func add_player(peer_id=8):
	print('joueur connecté ');
	var player = Player.instantiate();
	player.name = str(peer_id);
	print(player.name);
	add_child(player);
	
