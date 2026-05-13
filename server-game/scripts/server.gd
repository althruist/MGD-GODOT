extends Node

@onready var socket: SocketIO = $SocketIO
@onready var status_label: Label = $Label

signal httpResponse(response)

var _pending_event: String = ""
var _pending_payload: Variant = null

var game_id: String = ""
var player_token: String = ""
var player_symbol: String = ""
var current_turn: String = ""
var phase: String = "placement"
var winner: Variant = null

var board: Array = []
var plate_nodes: Array[Control] = []
var plate_buttons: Array[Button] = []

var selected_piece = -1
var last_message: String = ""

const ADJACENT = {
	0: [1, 3, 4],
	1: [0, 2, 4],
	2: [1, 4, 5],
	3: [0, 4, 6],
	4: [0, 1, 2, 3, 5, 6, 7, 8],
	5: [2, 4, 8],
	6: [3, 4, 7],
	7: [4, 6, 8],
	8: [4, 5, 7],
}


func _ready() -> void:
	socket.socket_connected.connect(_on_socket_connected)
	socket.event_received.connect(_on_socket_event_received)
	$RoomWindowUI.visible = true
	_cache_board_nodes()
	_set_game_state({"board": ["", "", "", "", "", "", "", "", ""]})

func create_game() -> void:
	_send_or_queue("create_game")


func join_game(id: String) -> void:
	game_id = id
	_send_or_queue("join_game", {"game_id": id})

func place_piece(position: int) -> void:
	_send_or_queue("place_piece", {
		"game_id": game_id,
		"player_token": player_token,
		"position": position
	})

func try_move_piece(position: int) -> void:
	if selected_piece == -1:
		selected_piece = position
		update_board_ui()
		return

	_send_or_queue("move_piece", {
		"game_id": game_id,
		"player_token": player_token,
		"from": selected_piece,
		"to": position
	})

	selected_piece = -1
	update_board_ui()

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
	var response: Variant = {}
	if data != null and data.size() > 0:
		response = data[0]

	match event:
		"create_game_response":
			game_id = response["game_id"]
			player_token = response["player_token"]
			_set_game_state(response.get("game", response))

		"join_game_response":
			if response.has("error"):
				_show_message(response["error"])
			else:
				game_id = response["game_id"]
				player_token = response["player_token"]
				_set_game_state(response.get("game", response))

		"game_ready":
			pass

		"game_state":
			_set_game_state(response)

		"place_piece_response":
			if response.has("error"):
				_show_message(response["error"])

		"move_piece_response":
			if response.has("error"):
				_show_message(response["error"])

	httpResponse.emit(response)

func update_board_ui() -> void:
	if board.size() < 9 or plate_nodes.size() < 9 or plate_buttons.size() < 9:
		return

	for i in range(9):
		var plate = plate_nodes[i]
		var btn = plate_buttons[i]
		var value = str(board[i])

		btn.text = value
		plate.modulate = _color_for_cell(value, i)

	update_status_label()

func _on_board_button_pressed(slot_number: int) -> void:
	var index = _slot_to_index(slot_number)

	if board.size() == 0:
		return

	if index < 0 or index >= board.size():
		return

	if player_token.is_empty() or game_id.is_empty():
		_show_message("Create or join a room")
		return

	if winner != null:
		return

	if not current_turn.is_empty() and current_turn != player_token:
		_show_message("Opponent's turn")
		return

	var cell = str(board[index])

	if phase == "placement":
		if cell == "":
			place_piece(index)
		else:
			_show_message("Choose an empty piece")
		return

	if cell == player_symbol:
		selected_piece = index
		_show_message("Choose an adjacent empty piece")
		return

	if selected_piece != -1 and cell == "":
		if not _is_adjacent(selected_piece, index):
			_show_message("Move to an adjacent piece")
			return

		try_move_piece(index)
		return

	selected_piece = -1
	_show_message("Select one of your pieces")


func _set_game_state(game: Dictionary) -> void:
	if game.has("game_id"):
		game_id = game["game_id"]

	if game.has("board"):
		board = game["board"]

	if game.has("phase"):
		phase = game["phase"]

	if game.has("current_turn"):
		current_turn = game["current_turn"]

	if game.has("winner"):
		winner = game["winner"]

	if game.has("players") and not player_token.is_empty() and game["players"].has(player_token):
		player_symbol = game["players"][player_token]["symbol"]

	if selected_piece != -1 and (selected_piece >= board.size() or str(board[selected_piece]) != player_symbol):
		selected_piece = -1

	last_message = ""
	update_board_ui()


func _cache_board_nodes() -> void:
	plate_nodes.clear()
	plate_buttons.clear()

	for plate in $Board/GridContainer.get_children():
		if plate is Control:
			plate_nodes.append(plate)
			plate_buttons.append(_find_button(plate))


func _find_button(node: Node) -> Button:
	if node is Button:
		return node

	for child in node.get_children():
		var button = _find_button(child)
		if button != null:
			return button

	return null


func _slot_to_index(slot_number: int) -> int:
	if slot_number >= 1 and slot_number <= 9:
		return slot_number - 1

	return slot_number


func _is_adjacent(from_index: int, to_index: int) -> bool:
	return ADJACENT.has(from_index) and to_index in ADJACENT[from_index]


func _color_for_cell(value: String, index: int) -> Color:
	if index == selected_piece:
		return Color(0.877, 0.882, 0.943, 1.0)

	if selected_piece != -1 and value == "" and _is_adjacent(selected_piece, index):
		return Color(0.751, 0.672, 0.949, 1.0)

	if value == "A":
		return Color(0.326, 0.499, 0.836, 1.0)

	if value == "B":
		return Color(0.865, 0.384, 0.292, 1.0)

	return Color(0.18521142, 0.2278361, 0.34383667, 1)


func _show_message(message: String) -> void:
	print(message)
	last_message = message
	update_board_ui()


func update_status_label() -> void:
	if status_label == null:
		return

	if not last_message.is_empty():
		status_label.text = last_message
		return

	if player_token.is_empty():
		status_label.text = "Create or Join a game"
		return

	if winner != null:
		status_label.text = "You Win!" if winner == player_token else "You Lose"
		return

	if current_turn.is_empty():
		status_label.text = "Waiting..."
		return

	if current_turn != player_token:
		status_label.text = "Opponent's turn"
		return

	if phase == "movement":
		status_label.text = "Your turn: Move"
	else:
		status_label.text = "Your turn: Place"
