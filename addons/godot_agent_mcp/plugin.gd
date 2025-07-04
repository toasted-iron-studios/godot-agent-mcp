@tool
extends EditorPlugin

const HttpServer = preload("res://addons/godot_agent_mcp/http_server.gd")
const MCPRouter = preload("res://addons/godot_agent_mcp/mcp/mcp_router.gd")
const CreateNodeTool = preload("res://addons/godot_agent_mcp/mcp/tools/create_node_tool.gd")
const ListNodesTool = preload("res://addons/godot_agent_mcp/mcp/tools/list_nodes_tool.gd")
const DeleteNodeTool = preload("res://addons/godot_agent_mcp/mcp/tools/delete_node_tool.gd")
const UpdateNodePropertyTool = preload("res://addons/godot_agent_mcp/mcp/tools/update_node_property_tool.gd")
const GetNodePropertiesTool = preload("res://addons/godot_agent_mcp/mcp/tools/get_node_properties_tool.gd")

var http_server: HttpServer

func _enter_tree():
	http_server = HttpServer.new()
	add_child(http_server)
	await http_server.ready

	http_server.start(MCPRouter.new([
		CreateNodeTool.new(),
		ListNodesTool.new(),
		DeleteNodeTool.new(),
		UpdateNodePropertyTool.new(),
		GetNodePropertiesTool.new()
	]), 8080)

	print("Godot Agent MCP plugin started")

func _exit_tree():
	if http_server:
		http_server.stop()
		remove_child(http_server)

	print("Godot Agent MCP plugin stopped")