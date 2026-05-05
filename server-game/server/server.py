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
            player_token: { "symbol": "X"},  # Creator is "X"
        },
        "board": [["" for _ in range(3)] for _ in range(3)], # Initialize empty 3x3 board
        "current_turn": player_token, # Creator starts first
        "winner": None
    }

    return game_id, player_token # Return the game ID and player token

def join_game(game_id):
    if game_id not in games:
        return None, "Game not found." # Game ID does not exist
    game = games[game_id]
    if len(game["players"]) >= 2:
        return None, "Game is full." # Game already has two players
    player_token = str(uuid.uuid4()) # Generate a unique player token
    game["players"][player_token] = {"symbol": "O"} # Joiner is "O"
    
    # Notify other players in the game room that changes happened in the game state (using sockets)
    #socketio.emit('game_state_changed', {'game_id': game_id}, room=game_id)
    
    return player_token, None # Return the player token and no error


# @app.route('/api/create_game', methods=['POST'])
# def api_create_game():
#     game_id, player_token = create_game()
#     return jsonify({
#         "game_id": game_id,
#         "player_token": player_token,
#         "logged_in": True
#     }), 200

# @app.route('/api/join_game', methods=['POST'])
# def api_join_game():
#     data = request.get_json()
#     game_id = data.get("game_id")
#     if not game_id:
#         return jsonify({"error": "Game ID is required."}), 400
#     player_token, error = join_game(game_id)
#     if not player_token:
#         return jsonify({"error": error}), 400
#     return jsonify({"player_token": player_token, "logged_in": True}), 200

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

if __name__ == '__main__':
    socketio.run(app, host="127.0.0.1", port=5000)
