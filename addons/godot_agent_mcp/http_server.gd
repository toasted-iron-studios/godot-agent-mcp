@tool
extends Node
class_name HttpServer

var tcp_server: TCPServer
var port: int = 8080
var running: bool = false

signal request_received(method: String, path: String, headers: Dictionary, body: String)

func _ready() -> void:
	tcp_server = TCPServer.new()

func start(server_port: int = 8080) -> bool:
	port = server_port
	var error: Error = tcp_server.listen(port, "127.0.0.1")
	if error != OK:
		print("Failed to start HTTP server on port ", port, ": ", error_string(error))
		return false
	
	running = true
	print("HTTP server started on port ", port)
	return true

func stop() -> void:
	tcp_server.stop()
	running = false
	print("HTTP server stopped")

func _process(_delta: float) -> void:
	if not running:
		return
	
	if tcp_server.is_connection_available():
		var client: StreamPeerTCP = tcp_server.take_connection()
		_handle_client(client)

func _handle_client(client: StreamPeerTCP) -> void:
	if not client:
		return
	
	# Read the request
	var request_text: String = ""
	var bytes_available: int = client.get_available_bytes()
	
	if bytes_available > 0:
		var data: PackedByteArray = client.get_data(bytes_available)[1]
		request_text = data.get_string_from_utf8()
	
	if request_text.is_empty():
		client.disconnect_from_host()
		return
	
	# Parse HTTP request
	var lines: PackedStringArray = request_text.split("\r\n")
	if lines.size() == 0:
		client.disconnect_from_host()
		return
	
	var request_line: PackedStringArray = lines[0].split(" ")
	if request_line.size() < 3:
		client.disconnect_from_host()
		return
	
	var method: String = request_line[0]
	var path: String = request_line[1]
	var headers: Dictionary = {}
	var body: String = ""
	
	# Parse headers
	var i: int = 1
	while i < lines.size() and not lines[i].is_empty():
		var header_parts: PackedStringArray = lines[i].split(": ", false, 1)
		if header_parts.size() == 2:
			headers[header_parts[0].to_lower()] = header_parts[1]
		i += 1
	
	# Get body if present
	if i + 1 < lines.size():
		body = lines[i + 1]
	
	# Handle the request
	var response: String = _handle_request(method, path, headers, body)
	
	# Send response
	client.put_data(response.to_utf8_buffer())
	client.disconnect_from_host()

func _handle_request(method: String, path: String, headers: Dictionary, body: String) -> String:
	request_received.emit(method, path, headers, body)
	
	# Default response
	var response_body: String = '{"status": "ok", "message": "MCP Server running"}'
	
	if method == "POST":
		response_body = _handle_mcp_request(body)
	
	var response: String = "HTTP/1.1 200 OK\r\n"
	response += "Content-Type: application/json\r\n"
	response += "Content-Length: " + str(response_body.length()) + "\r\n"
	response += "Access-Control-Allow-Origin: *\r\n"
	response += "Access-Control-Allow-Methods: GET, POST, OPTIONS\r\n"
	response += "Access-Control-Allow-Headers: Content-Type\r\n"
	response += "\r\n"
	response += response_body
	
	return response

func _handle_mcp_request(body: String) -> String:
	print("MCP: Received request - ", body)
	
	# Basic MCP JSON-RPC response
	var mcp_response: Dictionary = {
		"jsonrpc": "2.0",
		"id": null,
		"result": {
			"status": "ok",
			"message": "Request processed"
		}
	}
	
	return JSON.stringify(mcp_response)