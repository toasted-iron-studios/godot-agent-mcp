@tool
extends Node
class_name HttpServer

var _tcp_server: TCPServer
var _port: int = 8080
var _is_running: bool = false
var _clients: Array[StreamPeerTCP] = []
var _router: MCPRouter

signal server_started
signal server_stopped

func _ready():
	_tcp_server = TCPServer.new()
	print("MCP HTTP Server ready")

## Starts the HTTP server with the specified router and port
## Parameters:
##   - router: MCPRouter instance to handle MCP requests
##   - port: Port number to listen on (defaults to 8080)
## Returns: true if server started successfully, false otherwise
func start(router: MCPRouter, port: int = 8080) -> bool:
	_router = router
	
	if _is_running:
		push_warning("Server is already running")
		return false
	
	_port = port
	
	var error = _tcp_server.listen(_port, "127.0.0.1")
	if error != OK:
		push_error("Failed to start HTTP server on port %d: %s" % [_port, error_string(error)])
		return false
	
	_is_running = true
	print("MCP HTTP Server started on http://127.0.0.1:%d" % _port)
	server_started.emit()
	return true

## Stops the HTTP server and closes all client connections
func stop():
	if not _is_running:
		return
	
	for client in _clients:
		if client.get_status() == StreamPeerTCP.STATUS_CONNECTED:
			client.disconnect_from_host()
	_clients.clear()
	
	_tcp_server.stop()
	_is_running = false
	print("MCP HTTP Server stopped")
	server_stopped.emit()

func _process(_delta):
	if not _is_running:
		return
	
	if _tcp_server.is_connection_available():
		var client = _tcp_server.take_connection()
		_clients.append(client)
		print("Client connected from: %s" % client.get_connected_host())
	
	for i in range(_clients.size() - 1, -1, -1):
		var client = _clients[i]
		
		if client.get_status() != StreamPeerTCP.STATUS_CONNECTED:
			print("Client disconnected")
			_clients.remove_at(i)
			continue
		
		if client.get_available_bytes() > 0:
			var request_data = client.get_string(client.get_available_bytes())
			var response = _handle_http_request(request_data)
			client.put_data(response.to_utf8_buffer())
			
			client.disconnect_from_host()
			_clients.remove_at(i)

## Processes incoming HTTP requests and generates appropriate responses
## Parameters:
##   - request: Raw HTTP request string
## Returns: Complete HTTP response string including headers and body
func _handle_http_request(request: String) -> String:
	var lines = request.split("\r\n")
	if lines.size() == 0:
		return _create_http_response(400, "Bad Request", "Invalid request format")
	
	var request_line = lines[0].split(" ")
	if request_line.size() < 2:
		return _create_http_response(400, "Bad Request", "Invalid request line")
	
	var method = request_line[0]
	var path = request_line[1]
	
	var content_length = 0
	var content_type = ""
	var accept_header = ""
	var mcp_protocol_version = ""
	var origin_header = ""
	
	var body_start_index = -1
	for i in range(1, lines.size()):
		var line = lines[i]
		if line.is_empty():
			body_start_index = i + 1
			break
		
		var header_parts = line.split(":", false, 1)
		if header_parts.size() != 2:
			continue
		
		var header_name = header_parts[0].strip_edges().to_lower()
		var header_value = header_parts[1].strip_edges()
		
		match header_name:
			"content-length":
				content_length = header_value.to_int()
			"content-type":
				content_type = header_value
			"accept":
				accept_header = header_value
			"mcp-protocol-version":
				mcp_protocol_version = header_value
			"origin":
				origin_header = header_value
	
	if not origin_header.is_empty():
		if not (origin_header.contains("127.0.0.1") or origin_header.contains("localhost")):
			return _create_http_response(403, "Forbidden", "Origin not allowed")
	
	match method:
		"POST":
			return _handle_post_request(lines, body_start_index, content_length, content_type, accept_header, mcp_protocol_version)
		"GET":
			return _handle_get_request(path, accept_header, mcp_protocol_version)
		"OPTIONS":
			return _handle_options_request()
		_:
			return _create_http_response(405, "Method Not Allowed", "Method not supported")

## Handles HTTP POST requests containing JSON-RPC MCP messages
## Parameters:
##   - lines: Array of HTTP request lines
##   - body_start_index: Index where the request body begins
##   - content_length: Content-Length header value
##   - content_type: Content-Type header value
##   - accept_header: Accept header value
##   - mcp_protocol_version: MCP-Protocol-Version header value
## Returns: Complete HTTP response string
func _handle_post_request(lines: PackedStringArray, body_start_index: int, content_length: int, content_type: String, accept_header: String, mcp_protocol_version: String) -> String:
	if not content_type.begins_with("application/json"):
		return _create_http_response(400, "Bad Request", "Content-Type must be application/json")
	
	if not accept_header.is_empty() and not (accept_header.contains("application/json") or accept_header.contains("text/event-stream")):
		return _create_http_response(400, "Bad Request", "Accept header must include application/json or text/event-stream")
	
	var body = ""
	if body_start_index >= 0 and body_start_index < lines.size():
		for i in range(body_start_index, lines.size()):
			body += lines[i]
			if i < lines.size() - 1:
				body += "\r\n"
	
	var json = JSON.new()
	var parse_result = json.parse(body)
	if parse_result != OK:
		return _create_http_response(400, "Bad Request", "Invalid JSON")
	
	var request_data = json.data
	if not request_data is Dictionary:
		return _create_http_response(400, "Bad Request", "Request must be a JSON object")
	
	if not request_data.has("jsonrpc") or request_data["jsonrpc"] != "2.0":
		return _create_http_response(400, "Bad Request", "Invalid JSON-RPC version")
	
	if request_data.has("method"):
		var method = request_data.get("method", "")
		var params = request_data.get("params", {})
		var id = request_data.get("id", null)
		
		var response = _router.handle_request(method, params, id)
		var response_body = JSON.stringify(response)
		
		return _create_http_response(200, "OK", response_body, "application/json")
	
	elif request_data.has("result") or request_data.has("error"):
		return _create_http_response(202, "Accepted", "")
	
	else:
		return _create_http_response(400, "Bad Request", "Invalid JSON-RPC message")

## Handles HTTP GET requests (currently not supported)
## Parameters:
##   - path: Requested URL path
##   - accept_header: Accept header value
##   - mcp_protocol_version: MCP-Protocol-Version header value
## Returns: HTTP 405 Method Not Allowed response
func _handle_get_request(path: String, accept_header: String, mcp_protocol_version: String) -> String:
	return _create_http_response(405, "Method Not Allowed", "GET method not supported")

## Handles HTTP OPTIONS requests for CORS preflight
## Returns: HTTP response with appropriate CORS headers
func _handle_options_request() -> String:
	var headers = [
		"Access-Control-Allow-Origin: *",
		"Access-Control-Allow-Methods: POST, GET, OPTIONS",
		"Access-Control-Allow-Headers: Content-Type, Accept, MCP-Protocol-Version, Origin",
		"Access-Control-Max-Age: 86400"
	]
	return _create_http_response(200, "OK", "", "text/plain", headers)

## Creates a complete HTTP response with headers and body
## Parameters:
##   - status_code: HTTP status code (e.g., 200, 400, 500)
##   - status_text: HTTP status text (e.g., "OK", "Bad Request")
##   - body: Response body content
##   - content_type: Content-Type header value (defaults to "text/plain")
##   - additional_headers: Array of additional headers to include
## Returns: Complete HTTP response string ready to send to client
func _create_http_response(status_code: int, status_text: String, body: String, content_type: String = "text/plain", additional_headers: Array = []) -> String:
	var response = "HTTP/1.1 %d %s\r\n" % [status_code, status_text]
	
	var final_body = body + "\r\n"
	
	response += "Content-Length: %d\r\n" % final_body.length()
	response += "Content-Type: %s; charset=utf-8\r\n" % content_type
	response += "Connection: close\r\n"
	response += "Server: godot-agent-mcp/1.0.0\r\n"
	
	for header in additional_headers:
		response += "%s\r\n" % header
	
	response += "\r\n"
	response += final_body
	
	return response

func _exit_tree():
	stop() 