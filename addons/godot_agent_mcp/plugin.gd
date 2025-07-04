@tool
extends EditorPlugin

const HttpServer = preload("res://addons/godot_agent_mcp/http_server.gd")
const MCPRouter = preload("res://addons/godot_agent_mcp/mcp_routes.gd")
const CreateNodeTool = preload("res://addons/godot_agent_mcp/tools/create_node_tool.gd")

var http_server: HttpServer

func _enter_tree():
	# Store plugin in Engine metadata for tools to access
	Engine.set_meta("GodotAgentMCPPlugin", self)
	
	# Initialize tools
	var tools: Array[MCPTool] = [
		CreateNodeTool.new()
	]
	
	# Initialize router with tools
	var router = MCPRouter.new(tools)
	
	# Initialize HTTP server
	http_server = HttpServer.new()
	add_child(http_server)
	await http_server.ready
	http_server.start(router, 8080)

	
	print("Godot Agent MCP plugin started")

func _exit_tree():
	if http_server:
		http_server.stop()
		remove_child(http_server)
	
	# Remove from Engine metadata
	Engine.remove_meta("GodotAgentMCPPlugin")

	print("Godot Agent MCP plugin stopped")