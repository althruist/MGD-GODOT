from flask import Flask, request, jsonify
from flask_socketio import SocketIO, emit, join_room
import uuid
import random

app = Flask(__name__)
socketio = SocketIO(app, cors_allowed_origins="*")

@app.route("/")
def home():
    return "Hello Flask!"

games = {}
roomNums = []

def generate_room_num():
    while True:
        room_num = ''.join(str(random.randint(0, 9)) for _ in range(5))
        if room_num not in roomNums:
            roomNums.append(room_num)
            return room_num

def create_game():
    game_id = generate_room_num() # Generate a unique game ID
    player_token = str(uuid.uuid4()) # Generate a unique player token
    games[game_id] = {
        "players": {
            player_token: { "symbol": "A"},  # Creator is "X"
        },
        "board": [["O" for _ in range(3)] for _ in range(3)], # Initialize empty 3x3 board
        "current_turn": player_token, # Creator starts first
        "winner": None
    }

    return game_id, player_token # Return the game ID and player token

def get_board(game_id):
    print("board called")
    return games[game_id]["board"]

def set_board(game_id, position, player_token):
    games[game_id]["board"][position] = games[game_id]["players"][player_token]["symbol"]
    return games[game_id]["board"]

def join_game(game_id):
    if game_id not in games:
        return None, "Game not found." # Game ID does not exist
    game = games[game_id]
    if len(game["players"]) >= 2:
        return None, "Game is full." # Game already has two players
    player_token = str(uuid.uuid4()) # Generate a unique player token
    game["players"][player_token] = {"symbol": "B"} # Joiner is "O"
    
    # Notify other players in the game room that changes happened in the game state (using sockets)
    #socketio.emit('game_state_changed', {'game_id': game_id}, room=game_id)
    
    return player_token, None # Return the player token and no error

@socketio.on("create_game")
def socket_create_game(data=None):
    game_id, player_token = create_game()
    join_room(game_id)
    emit("create_game_response", {
        "game_id": game_id,
        "player_token": player_token
    })

@socketio.on("join_game")
def socket_join_game(data):
    print(get_board(data.get("game_id")))
    game_id = data.get("game_id") if data else None
    if not game_id:
        emit("join_game_response", {"error": "Game ID is required."})
        return

    player_token, error = join_game(game_id)
    if not player_token:
        emit("join_game_response", {"error": error})
        return

    join_room(game_id)
    emit("join_game_response", {
        "player_token": player_token,
        "logged_in": True
    }, to=game_id)

@socketio.on("get_board")
def socket_get_board(game_id):
    emit("get_board_response", {
        get_board(game_id)
    })

@socketio.on("set_board")
def socket_set_board(data):
    game_id = data.get["game_id"]
    position = data.get["position"]
    player_token = data.get["player_token"]

    if not game_id:
        emit("set_board_response", {"error": "Game ID not provided"})
        return
    elif not position:
        emit("set_board_response", {"error": "Position not provided"})
        return
    elif not player_token:
        emit("set_board_response", {"error": "Player not provided"})
        return
    
    set_board(data.get["game_id"], data.get["position"], data.get["player_token"])

    # emit("set_board_response", {
    #     get_board()
    # })

if __name__ == '__main__':
    socketio.run(app, host="127.0.0.1", port=5000)
