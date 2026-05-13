from flask import Flask
from flask_socketio import SocketIO, emit, join_room
import uuid
import random

app = Flask(__name__)
socketio = SocketIO(app, cors_allowed_origins="*")

games = {}
roomNums = []

BOARD_SIZE = 3

def index_to_coord(index):
    return (index // BOARD_SIZE, index % BOARD_SIZE)


def coord_to_index(row, col):
    return row * BOARD_SIZE + col

def generate_win_combinations():

    wins = []

    # Rows
    for row in range(BOARD_SIZE):

        wins.append([
            coord_to_index(row, 0),
            coord_to_index(row, 1),
            coord_to_index(row, 2)
        ])

    # Columns
    for col in range(BOARD_SIZE):

        wins.append([
            coord_to_index(0, col),
            coord_to_index(1, col),
            coord_to_index(2, col)
        ])

    # Main diagonal
    wins.append([
        coord_to_index(0, 0),
        coord_to_index(1, 1),
        coord_to_index(2, 2)
    ])

    # Secondary diagonal
    wins.append([
        coord_to_index(0, 2),
        coord_to_index(1, 1),
        coord_to_index(2, 0)
    ])

    return wins


WIN_COMBINATIONS = generate_win_combinations()

def generate_adjacency():

    adjacent = {
        index: set()
        for index in range(BOARD_SIZE * BOARD_SIZE)
    }

    for combo in WIN_COMBINATIONS:
        for index in range(len(combo) - 1):
            first = combo[index]
            second = combo[index + 1]
            adjacent[first].add(second)
            adjacent[second].add(first)

    return {
        index: sorted(neighbors)
        for index, neighbors in adjacent.items()
    }


ADJACENT = generate_adjacency()

def switch_turn(game):

    player_tokens = list(game["players"].keys())

    if game["current_turn"] == player_tokens[0]:
        game["current_turn"] = player_tokens[1]
    else:
        game["current_turn"] = player_tokens[0]


def check_winner(board, symbol):

    for combo in WIN_COMBINATIONS:

        won = True

        for pos in combo:

            if board[pos] != symbol:
                won = False
                break

        if won:
            return True

    return False


def generate_room_num():
    while True:
        room_num = ''.join(str(random.randint(0, 9)) for _ in range(5))
        if room_num not in roomNums:
            roomNums.append(room_num)
            return room_num

def create_game():

    game_id = generate_room_num()

    player_token = str(uuid.uuid4())

    games[game_id] = {

        "players": {
            player_token: {
                "symbol": "A",
                "pieces_placed": 0
            },
        },

        "board": [""] * 9,
        "current_turn": player_token,
        "winner": None,
        "phase": "placement"
    }

    return game_id, player_token

def get_game_state(game_id):

    game = games[game_id].copy()
    game["game_id"] = game_id
    return game

def join_game(game_id):

    if game_id not in games:
        return None, "Game not found."

    game = games[game_id]

    if len(game["players"]) >= 2:
        return None, "Game is full."

    player_token = str(uuid.uuid4())

    game["players"][player_token] = {
        "symbol": "B",
        "pieces_placed": 0
    }

    return player_token, None

def place_piece(game_id, position, player_token):

    if game_id not in games:
        return False, "Game not found."

    game = games[game_id]

    if game["winner"]:
        return False, "Game finished."

    if game["phase"] != "placement":
        return False, "Placement phase over."

    if len(game["players"]) < 2:
        return False, "Waiting for another player."

    if game["current_turn"] != player_token:
        return False, "Not your turn."

    if player_token not in game["players"]:
        return False, "Unknown player."

    if position is None:
        return False, "Position not provided."

    position = int(position)

    if position < 0 or position >= BOARD_SIZE * BOARD_SIZE:
        return False, "Invalid position."

    if game["board"][position] != "":
        return False, "Position occupied."

    player = game["players"][player_token]

    if player["pieces_placed"] >= 3:
        return False, "All pieces already placed."

    symbol = player["symbol"]

    game["board"][position] = symbol

    player["pieces_placed"] += 1

    # Winner check
    if check_winner(game["board"], symbol):

        game["winner"] = player_token

    else:

        total_pieces = sum(
            p["pieces_placed"]
            for p in game["players"].values()
        )

        if total_pieces == 6:
            game["phase"] = "movement"

        switch_turn(game)

    return True, game

def move_piece(game_id, from_pos, to_pos, player_token):

    if game_id not in games:
        return False, "Game not found."

    game = games[game_id]

    if game["winner"]:
        return False, "Game finished."

    if game["phase"] != "movement":
        return False, "Still in placement phase."

    if len(game["players"]) < 2:
        return False, "Waiting for another player."

    if game["current_turn"] != player_token:
        return False, "Not your turn."

    if player_token not in game["players"]:
        return False, "Unknown player."

    if from_pos is None or to_pos is None:
        return False, "Move positions not provided."

    from_pos = int(from_pos)
    to_pos = int(to_pos)

    if (
        from_pos < 0 or
        from_pos >= BOARD_SIZE * BOARD_SIZE or
        to_pos < 0 or
        to_pos >= BOARD_SIZE * BOARD_SIZE
    ):
        return False, "Invalid move."

    board = game["board"]

    player = game["players"][player_token]

    symbol = player["symbol"]

    if board[from_pos] != symbol:
        return False, "Not your piece."

    if board[to_pos] != "":
        return False, "Destination occupied."

    if to_pos not in ADJACENT[from_pos]:
        return False, "Invalid move."

    # Move piece
    board[from_pos] = ""
    board[to_pos] = symbol

    if check_winner(board, symbol):

        game["winner"] = player_token

    else:

        switch_turn(game)

    return True, game

@socketio.on("create_game")
def socket_create_game():

    game_id, player_token = create_game()

    join_room(game_id)

    emit("create_game_response", {
        "game_id": game_id,
        "player_token": player_token,
        "game": get_game_state(game_id)
    })


@socketio.on("join_game")
def socket_join_game(data):

    game_id = data.get("game_id") if data else None

    if not game_id:

        emit("join_game_response", {
            "error": "Game ID is required."
        })

        return

    player_token, error = join_game(game_id)

    if not player_token:

        emit("join_game_response", {
            "error": error
        })

        return

    join_room(game_id)

    emit("join_game_response", {
        "game_id": game_id,
        "player_token": player_token,
        "logged_in": True,
        "game": get_game_state(game_id)
    })

    emit("game_ready", {
        "game_id": game_id,
        "logged_in": True
    }, to=game_id)

    emit("game_state", get_game_state(game_id), to=game_id)

@socketio.on("place_piece")
def socket_place_piece(data):

    game_id = data.get("game_id")
    position = data.get("position")
    player_token = data.get("player_token")

    if not game_id:
        emit("place_piece_response", {
            "error": "Game ID not provided"
        })
        return

    success, result = place_piece(
        game_id,
        position,
        player_token
    )

    if not success:

        emit("place_piece_response", {
            "error": result
        })

        return

    emit("game_state", get_game_state(game_id), to=game_id)

@socketio.on("move_piece")
def socket_move_piece(data):

    game_id = data.get("game_id")
    from_pos = data.get("from")
    to_pos = data.get("to")
    player_token = data.get("player_token")

    if not game_id:

        emit("move_piece_response", {
            "error": "Game ID not provided"
        })

        return

    success, result = move_piece(
        game_id,
        from_pos,
        to_pos,
        player_token
    )

    if not success:

        emit("move_piece_response", {
            "error": result
        })

        return

    emit("game_state", get_game_state(game_id), to=game_id)

if __name__ == '__main__':

    socketio.run(
        app,
        host="127.0.0.1",
        port=5000
    )
