@tool
extends RefCounted
class_name MCPRoutes

const CreateNodeTool = preload("res://addons/godot_agent_mcp/tools/create_node_tool.gd")

enum ToolName {
	CREATE_NODE
}

const TOOL_NAME_MAP: Dictionary = {
	ToolName.CREATE_NODE: "create_node"
}

static func handle_request(method: String, params: Dictionary, id: Variant) -> Dictionary:
	var result: Dictionary = {}
	
	# Handle different MCP methods
	match method:
		"tools/list":
			result = _list_tools()
		"tools/call":
			var tool_name: String = params.get("name", "")
			var tool_arguments: Dictionary = params.get("arguments", {})
			result = _call_tool(tool_name, tool_arguments)
		_:
			return {
				"jsonrpc": "2.0",
				"id": id,
				"error": {"code": -32601, "message": "Method not found"}
			}
	
	return {
		"jsonrpc": "2.0",
		"id": id,
		"result": result
	}

static func _list_tools() -> Dictionary:
	return {
		"tools": [
			CreateNodeTool.get_schema()
		]
	}

static func _call_tool(tool_name: String, arguments: Dictionary) -> Dictionary:
	match tool_name:
		TOOL_NAME_MAP[ToolName.CREATE_NODE]:
			return CreateNodeTool.run(arguments)
		_:
			return {"error": "Tool not found: " + tool_name}