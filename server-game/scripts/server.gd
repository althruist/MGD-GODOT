extends Node

@onready var http = $HTTPRequest

signal httpResponse(response)

func create_game():
	var url = "http://127.0.0.1:5000/api/create_game"
	
	var headers = ["Content-Type: application/json"]
	
	http.request(url, headers, HTTPClient.METHOD_POST)
	
func join_game(game_id):
	var url = "http://127.0.0.1:5000/api/join_game"
	
	var body = {
		"game_id": game_id
	}
	
	var json_body = JSON.stringify(body)
	
	var headers = ["Content-Type: application/json"]
	
	http.request(url, headers, HTTPClient.METHOD_POST, json_body)
	
func _on_http_request_request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray) -> void:
	var response = JSON.parse_string(body.get_string_from_utf8())
	
	print("Response:", response)
	httpResponse.emit(response)
	if response_code == 200:
		emit_signal("httpResponse")
