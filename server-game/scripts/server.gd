extends Node

@onready var socket: SocketIO = $SocketIO

signal httpResponse(response)

var _pending_event: String = ""
var _pending_payload: Variant = null

func _ready() -> void:
	socket.socket_connected.connect(_on_socket_connected)
	socket.event_received.connect(_on_socket_event_received)

func create_game() -> void:
	_send_or_queue("create_game")

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
	if event != "create_game_response" and event != "join_game_response":
		return

	var response: Variant = data
	if data.size() > 0:
		response = data[0]

	print("Response:", response)
	httpResponse.emit(response)
