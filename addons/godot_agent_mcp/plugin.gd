@tool
extends EditorPlugin

const HttpServer = preload("res://addons/godot_agent_mcp/http_server.gd")

var http_server: HttpServer

func _enter_tree():
	http_server = HttpServer.new()
	add_child(http_server)
	await http_server.ready
	http_server.start(8080)

	
	print("Godot Agent MCP plugin started")

func _exit_tree():
	if http_server:
		http_server.stop()
		remove_child(http_server)

	print("Godot Agent MCP plugin stopped")