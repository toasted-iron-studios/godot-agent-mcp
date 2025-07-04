@tool
extends RefCounted
class_name MCPError

## Abstract base class for MCP errors
## All error types must implement get_message()

func get_message() -> String:
	push_error("MCPError.get_message() must be implemented by subclass") 
	return "Error"

func get_data() -> Dictionary:
	# Optional additional error data - can be overridden by subclasses
	return {}

## Base class for protocol-level errors (JSON-RPC errors)
class MCPProtocolError extends MCPError:
	func get_code() -> int:
		push_error("MCPProtocolError.get_code() must be implemented by subclass")
		return -32603
	
	## Convert error to JSON-RPC error format
	func to_json_rpc_error() -> Dictionary:
		return {
			"code": get_code(),
			"message": get_message(),
			"data": get_data()
		}

## Tool execution errors (MCP tool results with isError: true)
class MCPToolError extends MCPError:
	var error_message: String
	
	func _init(message: String):
		error_message = message
	
	func get_message() -> String:
		return error_message
	
	## Convert error to MCP tool result format
	func to_mcp_result() -> Dictionary:
		return {
			"content": [
				{
					"type": "text",
					"text": get_message()
				}
			],
			"isError": true
		}

## Tool Not Found Error (-32601: Method not found)
class MCPToolNotFoundError extends MCPProtocolError:
	var tool_name: String
	
	func _init(name: String):
		tool_name = name
	
	func get_code() -> int:
		return -32601
	
	func get_message() -> String:
		return "Tool not found: " + tool_name
	
	func get_data() -> Dictionary:
		return {"tool_name": tool_name}

## Method Not Found Error (-32601: Method not found)
class MCPMethodNotFoundError extends MCPProtocolError:
	var method_name: String
	
	func _init(name: String):
		method_name = name
	
	func get_code() -> int:
		return -32601
	
	func get_message() -> String:
		return "Method not found: " + method_name
	
	func get_data() -> Dictionary:
		return {"method": method_name}

## Invalid Parameters Error (-32602: Invalid params)
class MCPInvalidParametersError extends MCPProtocolError:
	var details: String
	
	func _init(error_details: String):
		details = error_details
	
	func get_code() -> int:
		return -32602
	
	func get_message() -> String:
		return "Invalid parameters: " + details
	
	func get_data() -> Dictionary:
		return {"details": details} 