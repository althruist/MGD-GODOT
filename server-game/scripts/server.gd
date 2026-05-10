extends Node

@onready var socket: SocketIO = $SocketIO

signal httpResponse(response)

var _pending_event: String = ""
var _pending_payload: Variant = null
var game_id:String = ""
var player_token_1:String = ""
var player_token_2:String = ""
var board:Array = []

func _ready() -> void:
	socket.socket_connected.connect(_on_socket_connected)
	socket.event_received.connect(_on_socket_event_received)
	$RoomWindowUI.visible = true

func create_game() -> void:
	_send_or_queue("create_game")

func set_board(piece: Control) -> void:
	_send_or_queue("set_board")

func get_board(game_id: Variant) -> void:
	_send_or_queue("get_board", {"game_id": game_id})

func join_game(game_id: Variant) -> void:
	_send_or_queue("join_game", {"game_id": game_id})

func _send_or_queue(event_name: String, payload: Variant = null) -> void:
	if socket.state != SocketIO.State.CONNECTED:
		_pending_event = event_name
		_pending_payload = payload
		socket.connect_socket()
		return

	socket.emit(event_name, payload)

func _on_socket_connected(_ns: String) -> void:
	if _pending_event.is_empty():
		return

	socket.emit(_pending_event, _pending_payload)
	_pending_event = ""
	_pending_payload = null

func _on_socket_event_received(event: String, data: Variant, _ns: String) -> void:
	var response: Variant = data
	if data.size() > 0:
		response = data[0]
	
	match event:
		"create_game_response":
			game_id = response["game_id"]
			player_token_1 = response["player_token"]

		"join_game_response":
			player_token_2 = response["player_token"]

		"get_board_response":
			board = response["board"]

	print("Response:", response)
	print("Game ID: ", game_id, "Player 1: ", player_token_1, "Player 2: ", player_token_2, "Board:", board)
	httpResponse.emit(response)
