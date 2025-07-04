@tool
extends RefCounted
class_name MCPRouter

const MCPError = preload("res://addons/godot_agent_mcp/mcp_error.gd")

var _tools: Array[MCPTool] = []

func _init(tools: Array[MCPTool]):
	_tools = tools

func handle_request(method: String, params: Dictionary, id: Variant) -> Dictionary:
	var result: Dictionary = {}
	match method:
		"initialize":
			result = {
				"protocolVersion": "2025-06-18",
				"capabilities": {
					"tools": {
						"listChanged": true
					}
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
			var tool_result = _call_tool(tool_name, tool_arguments)
			if tool_result.has("error"):
				if tool_result["error"] is MCPError.MCPProtocolError:
					var error_obj = tool_result["error"] as MCPError.MCPProtocolError
					return {
						"jsonrpc": "2.0",
						"id": id,
						"error": error_obj.to_json_rpc_error()
					}
				elif tool_result["error"] is MCPError.MCPToolError:
					var error_obj = tool_result["error"] as MCPError.MCPToolError
					result = error_obj.to_mcp_result()
			else:
				result = tool_result
		_:
			var error = MCPError.MCPMethodNotFoundError.new(method)
			return {
				"jsonrpc": "2.0",
				"id": id,
				"error": error.to_json_rpc_error()
			}
	
	return {
		"jsonrpc": "2.0",
		"id": id,
		"result": result
	}

func _list_tools() -> Dictionary:
	var tools_array = []
	for tool in _tools:
		var schema = format_tool_schema(tool)
		tools_array.append(schema)
	return {
		"tools": tools_array
	}

## Utility function to format a tool's schema for MCP
func format_tool_schema(tool: MCPTool) -> Dictionary:
	var input_schema = tool.get_input_schema()
	return {
		"name": tool.get_name(),
		"description": tool.get_description(),
		"inputSchema": input_schema.to_mcp_property()
	}
	
func _get_tool_by_name(tool_name: String) -> MCPTool:
	for tool in _tools:
		if tool.get_name() == tool_name:
			return tool
	return null

func _call_tool(tool_name: String, arguments: Dictionary) -> Dictionary:
	var tool = _get_tool_by_name(tool_name)
	if not tool:
		var error = MCPError.MCPToolNotFoundError.new(tool_name)
		return {"error": error}
	
	var validation_result: ZodotResult = tool.get_input_schema().parse(arguments)
	if not validation_result.ok():
		var error = MCPError.MCPInvalidParametersError.new(validation_result.error)
		return {"error": error}
	
	return tool.run(arguments)
