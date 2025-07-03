extends Control

@onready var host: Button = %Host
@onready var join: Button = %Join
@onready var exit: Button = %Exit

@export var main_scene: PackedScene
@export var player_scene: PackedScene

var peer = ENetMultiplayerPeer.new()

func _ready():
	host.pressed.connect(on_host_pressed)
	join.pressed.connect(on_join_pressed)
	exit.pressed.connect(on_exit_pressed)


func add_player(id: int):
	var player_instance = player_scene.instantiate() as CharacterBody3D
	player_instance.name = str(id)
	get_tree().get_first_node_in_group("player_set").add_child(player_instance)
	player_instance.global_position = Vector3(0, 20, 0)


func _on_peer_connected(id: int):
	print("Building connection successed ", id)
	add_player(id)


func on_host_pressed():
	var main_scene_instance = main_scene.instantiate() as Node3D
	get_tree().get_root().add_child(main_scene_instance)
	
	self.hide()
	
	add_player(1)
	
	#var error = peer.create_server(8000)
	#if error != OK:
		#print("Failed to create server ", error)
		#return
	#
	#multiplayer.multiplayer_peer = peer
	#
	#multiplayer.peer_connected.connect(_on_peer_connected)
	#add_player(multiplayer.get_unique_id())


func on_join_pressed():
	var main_scene_instance = main_scene.instantiate() as Node3D
	get_tree().get_root().add_child(main_scene_instance)
	
	self.hide()
	
	peer.create_client("127.0.0.1", 8000)
	multiplayer.multiplayer_peer = peer


func on_exit_pressed():
	get_tree().quit()
