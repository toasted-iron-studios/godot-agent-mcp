@tool
extends RefCounted
class_name MCPError

## Abstract base class for MCP errors
## All error types must implement get_message()

## Returns the error message string for this error
## Must be implemented by subclasses
func get_message() -> String:
	push_error("MCPError.get_message() must be implemented by subclass") 
	return "Error"

## Returns additional error data as a Dictionary
## Can be overridden by subclasses to provide context-specific data
func get_data() -> Dictionary:
	return {}

## Base class for protocol-level errors (JSON-RPC errors)
class MCPProtocolError extends MCPError:
	## Returns the JSON-RPC error code for this error type
	## Must be implemented by subclasses
	func get_code() -> int:
		push_error("MCPProtocolError.get_code() must be implemented by subclass")
		return -32603
	
	## Convert error to JSON-RPC error format
	## Returns a Dictionary compatible with JSON-RPC 2.0 error responses
	func to_json_rpc_error() -> Dictionary:
		return {
			"code": get_code(),
			"message": get_message(),
			"data": get_data()
		}

## Tool execution errors (MCP tool results with isError: true)
class MCPToolError extends MCPError:
	var error_message: String
	
	## Creates a new tool error with the specified message
	func _init(message: String):
		error_message = message
	
	## Returns the error message for this tool error
	func get_message() -> String:
		return error_message
	
	## Convert error to MCP tool result format
	## Returns a Dictionary formatted as an MCP tool error result
	func to_mcp_result() -> Dictionary:
		return {
			"content": [
				{
					"type": "text",
					"text": "Error: " + get_message()
				}
			],
			"isError": true
		}

## Tool Not Found Error (-32601: Method not found)
class MCPToolNotFoundError extends MCPProtocolError:
	var tool_name: String
	
	## Creates a new tool not found error for the specified tool name
	func _init(name: String):
		tool_name = name
	
	## Returns the JSON-RPC error code for method not found
	func get_code() -> int:
		return -32601
	
	## Returns the error message including the tool name
	func get_message() -> String:
		return "Tool not found: " + tool_name
	
	## Returns error data including the tool name that was not found
	func get_data() -> Dictionary:
		return {"tool_name": tool_name}

## Method Not Found Error (-32601: Method not found)
class MCPMethodNotFoundError extends MCPProtocolError:
	var method_name: String
	
	## Creates a new method not found error for the specified method name
	func _init(name: String):
		method_name = name
	
	## Returns the JSON-RPC error code for method not found
	func get_code() -> int:
		return -32601
	
	## Returns the error message including the method name
	func get_message() -> String:
		return "Method not found: " + method_name
	
	## Returns error data including the method name that was not found
	func get_data() -> Dictionary:
		return {"method": method_name}

## Invalid Parameters Error (-32602: Invalid params)
class MCPInvalidParametersError extends MCPProtocolError:
	var details: String
	
	## Creates a new invalid parameters error with detailed error information
	func _init(error_details: String):
		details = error_details
	
	## Returns the JSON-RPC error code for invalid parameters
	func get_code() -> int:
		return -32602
	
	## Returns the error message including validation details
	func get_message() -> String:
		return "Invalid parameters: " + details
	
	## Returns error data including validation failure details
	func get_data() -> Dictionary:
		return {"details": details} 