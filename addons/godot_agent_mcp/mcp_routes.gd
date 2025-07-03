@tool
extends RefCounted
class_name MCPRoutes

const CreateNodeTool = preload("res://addons/godot_agent_mcp/tools/create_node_tool.gd")

const TOOLS: Array = [
	CreateNodeTool
]

static func handle_request(method: String, params: Dictionary, id: Variant) -> Dictionary:
	var result: Dictionary = {}
	match method:
		"initialize":
			result = {
				"capabilities": {
					"tools": _list_tools()
				},
				"serverInfo": {
					"name": "godot-agent-mcp",
					"version": "1.0.0"
				}
			}
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
	var tools_array = []
	for tool_class in TOOLS:
		var schema = format_tool_schema(tool_class)
		tools_array.append(schema)
	return {
		"tools": tools_array
	}

## Utility function to format a tool's schema for MCP
static func format_tool_schema(tool_class) -> Dictionary:
	var input_schema = tool_class.get_input_schema()
	return {
		"name": tool_class.get_name(),
		"description": tool_class.get_description(),
		"inputSchema": input_schema.to_mcp_property()
	}
	
static func _get_tool_by_name(tool_name: String):
	for tool_class in TOOLS:
		if tool_class.get_name() == tool_name:
			return tool_class
	return null

static func _call_tool(tool_name: String, arguments: Dictionary) -> Dictionary:
	var tool_class = _get_tool_by_name(tool_name)
	if not tool_class:
		return {"error": "Tool not found: " + tool_name}
	
	var validation_result: ZodotResult = tool_class.get_input_schema().parse(arguments)
	if not validation_result.ok():
		return {"error": "Invalid parameters: " + validation_result.error}
	
	return tool_class.run(arguments)
